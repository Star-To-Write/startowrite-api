import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { neon } from "@neondatabase/serverless";

dotenv.config();

const sql = neon(process.env.DATABASE_URL);
const app = express();
app.use(cors());
app.use(express.json());

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
Valid values for `submission_type` are:
- poetry
- essay
- short_story
- awareness
- other
If `submission_type` is not provided, it returns all submissions.
*/
app.get("/submissions", async (req, res) => {
  try {
    const { submission_type } = req.query;

    let rows;
    if (submission_type) {
      if (
        !submission_type.includes(
          "poetry",
          "essay",
          "short_story",
          "awareness",
          "other"
        )
      )
        return res.status(422).send({ error: "Invalid category" });
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
- submission_type (must be one of: poetry, essay, short_story, awareness, other)
- disclaimer
- author
- author_instagram
- author_bio
*/
// TODO: Accept multiple submissions in a single request
app.post("/submissions", async (req, res) => {
  try {
    const {
      title,
      content,
      submission_type,
      disclaimer,
      author,
      author_instagram,
      author_bio,
    } = req.body;

    if (!title || !content || !submission_type || !disclaimer || !author) {
      return res.status(422).send({ error: "Missing required fields" });
    }

    if (
      !submission_type.includes(
        "poetry",
        "essay",
        "short_story",
        "awareness",
        "other"
      )
    ) {
      return res.status(422).send({ error: "Invalid submission type" });
    }

    if (!author_instagram) author_instagram == null;
    const result = await sql`
      INSERT INTO submissions (title, content, submission_type, disclaimer, author, author_instagram)
      VALUES (${title}, ${content}, ${submission_type}, ${disclaimer}, ${author}, ${author_instagram})
      RETURNING id, title, submission_type
    `;
    console.log(
      `New post: ${result[0].title} of type ${result[0].submission_type} (#${result[0].id})`
    );
    res.status(201).json(result);
  } catch (e) {
    console.error(e);
    res.status(500).send("Internal Server Error");
  }
});

// POST /comments
// Add a new comment
app.post("/comments", async (req, res) => {
  try {
    const { subs_id, parent_id, content, author } = req.body;

    if (parent_id === "") parent_id = null; // allow parent_id to be optional

    if (!subs_id || !content || !author) {
      return res.status(422).send({ error: "Missing required fields" });
    }

    const result = await sql`
      INSERT INTO comments (subs_id, parent_id, content, author)
      VALUES (${subs_id}, ${parent_id}, ${content}, ${author})
      RETURNING id, subs_id, content, author
      `;
    console.log(`New comment on submission #${subs_id}: ${result[0].content}`);
    res.status(201).json(result);
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

// example fetch request
// await fetch("http://localhost:6969/submissions", {
//   headers: {
//     "x-api-key": "...",
//   },
// })
//   .then((res) => res.json())
//   .then((data) => console.log(data))
//   .catch((e) => console.error(e));

// Create new post
// await fetch("http://localhost:6969/submissions", {
//   method: "POST",
//   headers: {
//     "Content-Type": "application/json",
//     "x-api-key": "...",
//   },
//   body: JSON.stringify({
//     title: "Test Submission",
//     content: "This is a test submission content.",
//     submission_type: "poetry",
//     disclaimer: "This is a test disclaimer.",
//     author: "John Doe",
//     author_instagram: "@johndoe",
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
//     "x-api-key": "...",
//   },
//   body: JSON.stringify({
//     subs_id: 4,
//     parent_id: null,
//     content: "This is a test comment.",
//     author: "Jane Doe",
//   }),
// })
//   .then((res) => res.json())
//   .then((data) => console.log(data))
//   .catch((e) => console.error(e));

// await fetch("http://localhost:6969/submissions", {
//   method: "POST",
//   headers: {
//     "Content-Type": "application/json",
//     "x-api-key": "...",
//   },
//   body: JSON.stringify({
//     title: "Test Submission",
//     content: "This is a test submission content.",
//     submission_type: "poetry",
//     disclaimer: "This is a test disclaimer.",
//     author: "John Doe",
//   }),
// })
//   .then((res) => res.json())
//   .then((data) => console.log(data))
//   .catch((e) => console.error(e));
