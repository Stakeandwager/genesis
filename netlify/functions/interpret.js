// --- 020: the key stays on the server ---
//
// The web build ships with no api_key.txt, because anything under res:// is
// packed into index.pck and anyone can download and read it. A published key
// is a spent key. So the browser asks this function, and this function - which
// nobody can read - adds the key and asks Google.
//
// What this is NOT: a general proxy. It forwards exactly one model's
// generateContent call and nothing else. A function that forwards whatever it
// is handed is an open relay with somebody's credit card behind it.

const MODEL = "gemini-3-pro-preview";
const ENDPOINT =
  "https://generativelanguage.googleapis.com/v1beta/models/" +
  MODEL +
  ":generateContent";

// A Genesis request is a system prompt, a short history and a config. Twice
// the largest one seen is ample, and a cap means a stranger cannot post a
// megabyte of text at somebody else's expense.
const MAX_BODY = 200 * 1024;

export default async (request) => {
  if (request.method !== "POST") {
    return new Response(JSON.stringify({ error: "POST only" }), {
      status: 405,
      headers: { "content-type": "application/json" },
    });
  }

  const key = Netlify.env.get("GEMINI_API_KEY");
  if (!key) {
    // Said plainly rather than failing obscurely: a build without a key is a
    // deployment mistake, not a player's.
    return new Response(
      JSON.stringify({
        error: {
          code: 503,
          message:
            "This Genesis has no AI configured. Raw JSON commands still work.",
          status: "UNAVAILABLE",
        },
      }),
      { status: 503, headers: { "content-type": "application/json" } }
    );
  }

  const text = await request.text();
  if (text.length > MAX_BODY) {
    return new Response(
      JSON.stringify({ error: { code: 413, message: "Request too large." } }),
      { status: 413, headers: { "content-type": "application/json" } }
    );
  }

  // Only the three fields Genesis sends are passed on. Anything else a caller
  // adds is dropped rather than forwarded, so this cannot be used to reach a
  // different model, a different tool, or a different account's quota.
  let body;
  try {
    const sent = JSON.parse(text);
    body = {
      system_instruction: sent.system_instruction,
      contents: sent.contents,
      generationConfig: sent.generationConfig,
    };
  } catch (e) {
    return new Response(
      JSON.stringify({ error: { code: 400, message: "Not valid JSON." } }),
      { status: 400, headers: { "content-type": "application/json" } }
    );
  }

  const answer = await fetch(ENDPOINT, {
    method: "POST",
    headers: { "content-type": "application/json", "x-goog-api-key": key },
    body: JSON.stringify(body),
  });

  // Google's own answer and status are returned unchanged, so Genesis's
  // existing error handling - "the AI service is busy", "the key was refused" -
  // keeps working exactly as it does on the desktop.
  return new Response(await answer.text(), {
    status: answer.status,
    headers: { "content-type": "application/json" },
  });
};

export const config = { path: "/api/interpret" };
