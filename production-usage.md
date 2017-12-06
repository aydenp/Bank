# SECURITY ADVISORY: Production Usage

Please read the following if you intend to ship any of the code in this project.

---

This app is **NOT INTENDED TO BE DISTRIBUTED TO MULTIPLE PEOPLE, BUT IS MEANT FOR PERSONAL USE**.

## What does this mean?

The app is meant to be used by one person, you. Compiling the app and distributing it to others is dangerous, as your Plaid API secret and client ID should never be distributed to others, but are safe for you to have.

## Why does this matter?

Your Plaid API secret and client ID should never be distributd to others, but are safe for you to have for personal usage of this app. Production uses of the Plaid API would require a server backend to do the authenticated requests with the client ID and secret.

## Why didn't you use a server backend?

Since the app is for personal use and as a proof-of-concept, it didn't make sense to code an entire server to take care of that. Doing so also gives me the responsibility of storing user data properly, and makes this app harder to use and maintain. For personal use, this is the best way to go.

## What am I risking?

Someone could use your Plaid account (not your banking details, those are safe) to make malicious requests and get you blocked from using Plaid.
