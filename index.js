import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { neon } from "@neondatabase/serverless";

dotenv.config();

const sql = neon(process.env.DATABASE_URL);
const app = express();
app.use(cors());
app.use(express.json());

// submission categories - also used for the slugging
const validCategories = ['poetry', 'short-stories', 'essays-opinions-research-papers', 'writing-to-spread-awareness', 'other-creative-works', 'issues', 'interviews']

// health check
app.get("/", (req, res) => {
  try {
    res.send("Service active!");
  } catch (e) {
    console.error(e);
    res.status(500).send("Internal Server Error");
  }
});

// MIDDLEWARE - this prevents unauthorized access
app.use((req, res, next) => {
  const apiKey = req.headers["x-api-key"];
  if (apiKey !== process.env.API_KEY) {
    return res
      .status(401)
      .send("You are not authorized to access this resource.");
  }
  next();
});

// GET /submissions
/*
FILTERING:
This endpoint accepts a query parameter `submission_type` to filter submissions by type.
Valid values for `submission_type` are listed in the validCategories
If `submission_type` is not provided, it returns all submissions.
*/
app.get("/submissions", async (req, res) => {
  try {
    const { submission_type } = req.query;

    let rows;
    if (submission_type) {
      if (!validCategories.some(term => submission_type.includes(term))) {
        return res.status(422).send({ error: "Invalid category" });
      }
      rows = await sql`
        SELECT * FROM submissions
        WHERE submission_type = ${submission_type}
        ORDER BY created_at DESC
        `;
    } else {
      rows = await sql`
        SELECT * FROM submissions
        ORDER BY created_at DESC
        `;
    }

    const results = await Promise.all(
      rows.map(async (submission) => {
        const comments = await sql`
        SELECT * FROM comments
        WHERE subs_id = ${submission.id}`;

        return {
          ...submission,
          comments: comments,
        };
      })
    );

    res.json(results);
  } catch (e) {
    console.error(e);
    res.status(500).send("Internal Server Error");
  }
});

// POST /submissions
/*
This endpoint is used to create a new submission.
It requires the following fields in the request body:
- title
- content
- submission_type (must be one of the validCategories)
- disclaimer (optional)
- author (optional, defaults to 'Anonymous Writer')
- author_socials (optional)
- author_bio (optional)
- bibliography (optional)
*/
app.post("/submissions", async (req, res) => {
  try {
    const {
      title,
      content,
      submission_type,
      disclaimer,
      author,
      author_socials,
      author_bio,
      bibliography,
    } = req.body;

    if (!title || !content || !submission_type) {
      return res.status(422).send({ error: "Missing required fields: title, content, submission_type" });
    }

    if (!validCategories.includes(submission_type)) {
      return res.status(422).send({ 
        error: "Invalid submission type", 
        validCategories: validCategories 
      });
    }

    const result = await sql`
      INSERT INTO submissions (title, content, submission_type, disclaimer, author, author_socials, author_bio, bibliography)
      VALUES (${title}, ${content}, ${submission_type}, ${disclaimer || null}, ${author || 'Anonymous Writer'}, ${author_socials || null}, ${author_bio || null}, ${bibliography || null})
      RETURNING id, title, submission_type, author, created_at
    `;
    
    console.log(
      `New post: ${result[0].title} by ${result[0].author} of type ${result[0].submission_type} (#${result[0].id})`
    );
    res.status(201).json(result[0]);
  } catch (e) {
    console.error(e);
    res.status(500).send("Internal Server Error");
  }
});

// POST /comments
// Add a new comment
app.post("/comments", async (req, res) => {
  try {
    let { subs_id, parent_id, content, author } = req.body;

    if (parent_id === "" || parent_id === undefined) {
      parent_id = null; // allow parent_id to be optional
    }

    if (!subs_id || !content || !author) {
      return res.status(422).send({ error: "Missing required fields: subs_id, content, author" });
    }

    const result = await sql`
      INSERT INTO comments (subs_id, parent_id, content, author)
      VALUES (${subs_id}, ${parent_id}, ${content}, ${author})
      RETURNING id, subs_id, parent_id, content, author, created_at
      `;
    console.log(`New comment on submission #${subs_id} by ${result[0].author}: ${result[0].content.substring(0, 50)}...`);
    res.status(201).json(result[0]);
  } catch (e) {
    console.error(e);
    res.status(500).send("Internal Server Error");
  }
});

app.listen(process.env.PORT, () => {
  console.log("API running on port", process.env.PORT);
});

// copied this from stackoverflow, this is to generate API Keys
// (async function (){
//     let k = await window.crypto.subtle.generateKey(
//       {name: "AES-GCM", length: 256}, true, ["encrypt", "decrypt"]);
//     const jwk = await crypto.subtle.exportKey("jwk", k)
//     console.log(jwk.k)
//   })()

// EXAMPLE REQUESTS:

// Get all submissions
// await fetch("http://localhost:6969/submissions", {
//   headers: {
//     "x-api-key": "your-api-key",
//   },
// })
//   .then((res) => res.json())
//   .then((data) => console.log(data))
//   .catch((e) => console.error(e));

// Get submissions filtered by category
// await fetch("http://localhost:6969/submissions?submission_type=poetry", {
//   headers: {
//     "x-api-key": "your-api-key",
//   },
// })
//   .then((res) => res.json())
//   .then((data) => console.log(data))
//   .catch((e) => console.error(e));

// Create new post with new schema
// await fetch("http://localhost:6969/submissions", {
//   method: "POST",
//   headers: {
//     "Content-Type": "application/json",
//     "x-api-key": "your-api-key",
//   },
//   body: JSON.stringify({
//     title: "Test Submission with New Schema",
//     content: "This is a test submission content with the updated schema.",
//     submission_type: "poetry",
//     disclaimer: "This is a test disclaimer.",
//     author: "John Doe",
//     author_socials: "Twitter: @johndoe, Instagram: @john.doe.writer",
//     author_bio: "John Doe is a writer and poet exploring themes of identity.",
//     bibliography: "<p><strong>Influences:</strong></p><ul><li>Whitman, Walt. <em>Leaves of Grass</em>.</li></ul>"
//   }),
// })
//   .then((res) => res.json())
//   .then((data) => console.log(data))
//   .catch((e) => console.error(e));

// Create minimal post (only required fields)
// await fetch("http://localhost:6969/submissions", {
//   method: "POST",
//   headers: {
//     "Content-Type": "application/json",
//     "x-api-key": "your-api-key",
//   },
//   body: JSON.stringify({
//     title: "Minimal Test Post",
//     content: "This post only has the required fields.",
//     submission_type: "other-creative-works"
//   }),
// })
//   .then((res) => res.json())
//   .then((data) => console.log(data))
//   .catch((e) => console.error(e));

// Create new comment
// await fetch("http://localhost:6969/comments", {
//   method: "POST",
//   headers: {
//     "Content-Type": "application/json",
//     "x-api-key": "your-api-key",
//   },
//   body: JSON.stringify({
//     subs_id: 1,
//     parent_id: null, // top-level comment
//     content: "This is a test comment on the new system.",
//     author: "Jane Doe",
//   }),
// })
//   .then((res) => res.json())
//   .then((data) => console.log(data))
//   .catch((e) => console.error(e));

// Create reply to existing comment
// await fetch("http://localhost:6969/comments", {
//   method: "POST",
//   headers: {
//     "Content-Type": "application/json",
//     "x-api-key": "your-api-key",
//   },
//   body: JSON.stringify({
//     subs_id: 1,
//     parent_id: 2, // replying to comment with id 2
//     content: "This is a reply to another comment.",
//     author: "Reply Author",
//   }),
// })
//   .then((res) => res.json())
//   .then((data) => console.log(data))
//   .catch((e) => console.error(e));