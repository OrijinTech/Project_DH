/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

import * as functions from "firebase-functions";
import {OpenAI} from "openai";

// Replace with your OpenAI API key
const OPENAI_API_KEY = functions.config().openai.api_key;

const openai = new OpenAI({
  apiKey: OPENAI_API_KEY,
});

// Type definition for chat completion messages
type ChatCompletionMessage = {
  role: "system" | "user" | "assistant";
  content: string;
};

// Function to handle ChatGPT queries
export const generateResponse = functions.https.onCall(
  async (data) => {
    const messages: ChatCompletionMessage[] = data.messages;
    const model = data.model || "gpt-4";

    try {
      const response = await openai.chat.completions.create({
        model: model,
        messages: messages,
      });

      return response.choices[0].message;
    } catch (error) {
      console.error("Error calling OpenAI API:", error);
      throw new functions.https.HttpsError(
        "internal",
        "OpenAI API call failed"
      );
    }
  }
);

// Function to validate food items
export const validFoodItem = functions.https.onCall(
  async (data) => {
    const imageUrl = data.imageUrl;

    try {
      const messages: ChatCompletionMessage[] = [
        {
          role: "system",
          content:
            "You are a nutrition expert. Please tell me if the image " +
            "contains any types of food.",
        },
        {
          role: "system",
          content: "Please only give YES or NO answer.",
        },
        {
          role: "system",
          content: "If you are not sure, then answer NO.",
        },
        {
          role: "user",
          content: imageUrl,
        },
      ];

      const response = await openai.chat.completions.create({
        model: "gpt-4",
        messages: messages,
      });

      const answer = response.choices[0].message?.content
        ?.trim()
        .toUpperCase();
      return {valid: answer === "YES"};
    } catch (error) {
      console.error("Error calling OpenAI API:", error);
      throw new functions.https.HttpsError(
        "internal",
        "OpenAI API call failed"
      );
    }
  }
);

// Function to generate calorie count from image
export const generateCalories = functions.https.onCall(
  async (data) => {
    const imageUrl = data.imageUrl;

    try {
      const messages: ChatCompletionMessage[] = [
        {
          role: "system",
          content:
            "You are a nutrition expert. Please calculate the " +
            "calories of the provided image.",
        },
        {
          role: "system",
          content:
            "Please only provide the calorie number, do not give " +
            "any textual explanation.",
        },
        {
          role: "user",
          content: imageUrl,
        },
      ];

      const response = await openai.chat.completions.create({
        model: "gpt-4",
        messages: messages,
      });

      const calorieString = response.choices[0].message?.content?.trim();
      const calorieNumber = parseInt(calorieString || "0", 10);
      return {calories: calorieNumber};
    } catch (error) {
      console.error("Error calling OpenAI API:", error);
      throw new functions.https.HttpsError(
        "internal",
        "OpenAI API call failed"
      );
    }
  }
);

// Function to generate meal name from image
export const generateMealName = functions.https.onCall(
  async (data) => {
    const imageUrl = data.imageUrl;

    try {
      const messages: ChatCompletionMessage[] = [
        {
          role: "system",
          content:
            "You are a nutrition expert. Please predict the name " +
            "of the food.",
        },
        {
          role: "system",
          content: "Please only provide the name of the food.",
        },
        {
          role: "user",
          content: imageUrl,
        },
      ];

      const response = await openai.chat.completions.create({
        model: "gpt-4",
        messages: messages,
      });

      const mealName = response.choices[0].message?.content?.trim();
      return {mealName: mealName};
    } catch (error) {
      console.error("Error calling OpenAI API:", error);
      throw new functions.https.HttpsError(
        "internal",
        "OpenAI API call failed"
      );
    }
  }
);
