// add_faqs.js
const admin = require('firebase-admin');
const serviceAccount = require('../../../serviceAccountKey.json'); // Download this from Firebase Console > Project Settings > Service Accounts

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

const faqs = [

  // General FAQs
  {
    category: 'General',
    question: 'What is RailPeak?',
    answer: 'RailPeak is a modern train ticketing and travel management app designed to make your rail journeys seamless and enjoyable.'
  },
  {
    category: 'General',
    question: 'Is the RailPeak App free?',
    answer: 'Yes, RailPeak is free to download and use. Some premium features may require payment.'
  },
  {
    category: 'General',
    question: 'How can I order train tickets?',
    answer: 'You can order train tickets by searching for your route, selecting your train, and completing the booking process in the RailPeak app.'
  },
  {
    category: 'General',
    question: 'How can I make payment?',
    answer: 'RailPeak supports multiple payment methods including credit/debit cards, digital wallets, and more.'
  },
  {
    category: 'General',
    question: 'How can I cancel a ticket?',
    answer: 'To cancel a ticket, go to My Tickets, select the ticket, and tap Cancel. Refunds are processed as per our policy.'
  },
  {
    category: 'General',
    question: 'How can I use the discount?',
    answer: 'Discounts can be applied at checkout if you have a valid promo code or eligible offer.'
  },
  
  // Account FAQs
  {
    question: "How do I create an account?",
    answer: "Tap on 'Sign Up' and follow the instructions to create your account.",
    category: "Account"
  },
  {
    question: "How do I reset my password?",
    answer: "Go to the login screen, tap 'Forgot Password', and follow the instructions.",
    category: "Account"
  },
  {
    question: "How do I update my email address?",
    answer: "Go to Account Settings and tap on 'Edit Email' to update your email address.",
    category: "Account"
  },
  {
    question: "Can I delete my account?",
    answer: "Yes, please contact customer support to request account deletion.",
    category: "Account"
  },
  {
    question: "How do I change my profile picture?",
    answer: "In Account Settings, tap your profile image to upload a new picture.",
    category: "Account"
  },
  {
    question: "Why can't I log in to my account?",
    answer: "Check your email and password, or reset your password if you've forgotten it.",
    category: "Account"
  },
  
  // Service FAQs
  {
    question: "What services does Railify offer?",
    answer: "Railify offers train ticket booking, real-time schedules, and customer support.",
    category: "Service"
  },
  {
    question: "How do I contact customer service?",
    answer: "Go to the Help Center and select 'Contact us' for support options.",
    category: "Service"
  },
  {
    question: "Are there any loyalty programs?",
    answer: "Yes, frequent travelers can join our loyalty program for exclusive rewards.",
    category: "Service"
  },
  {
    question: "How do I get notified about service disruptions?",
    answer: "Enable push notifications in the app to receive real-time service updates.",
    category: "Service"
  },
  {
    question: "Can I book group tickets?",
    answer: "Yes, you can book tickets for up to 10 people in a single transaction.",
    category: "Service"
  },
  {
    question: "Is there a mobile app for iOS and Android?",
    answer: "Yes, Railify is available on both iOS and Android platforms.",
    category: "Service"
  },
  // Ticket FAQs
  {
    question: "How do I view my tickets?",
    answer: "Your tickets are available in the 'My Tickets' section of the app.",
    category: "Ticket"
  },
  {
    question: "Can I transfer my ticket to someone else?",
    answer: "Currently, tickets are non-transferable.",
    category: "Ticket"
  },
  {
    question: "How do I cancel a ticket?",
    answer: "Go to 'My Tickets', select the ticket, and tap 'Cancel Ticket'.",
    category: "Ticket"
  },
  {
    question: "How do I get a refund for a cancelled ticket?",
    answer: "Refunds are processed automatically to your original payment method within 5-7 business days.",
    category: "Ticket"
  },
  {
    question: "Can I change my travel date after booking?",
    answer: "Currently, changing travel dates is not supported. Please cancel and rebook.",
    category: "Ticket"
  },
  {
    question: "What should I do if I lose my ticket?",
    answer: "All your tickets are stored in the app under 'My Tickets'.",
    category: "Ticket"
  },
];

async function addFaqs() {
  for (const faq of faqs) {
    await db.collection('faqs').add(faq);
    console.log(`Added FAQ: ${faq.question}`);
  }
  console.log('All FAQs added!');
}

addFaqs().catch(console.error); 