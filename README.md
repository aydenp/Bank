# Bank

A simple iOS app for viewing your bank account balance and transactions.

## How does it work?

This app uses the [Plaid API](https://www.plaid.com) to fetch information about your bank account(s).

## How can I use it?

1. You're going to need some Plaid API keys, which you can apply for with [Plaid](https://www.plaid.com).

2. Once you've done this, move the file I've provided named `Plaid.example.plist` to `Plaid.plist`.

3. Open the Xcode project (Bank.xcworkspace) in Xcode.

4. Fill in Plaid.plist with your API information from Plaid.

5. Build the app and install it on your iOS device.

## SECURITY ADVISORY: Production Usage

This app is **NOT INTENDED TO BE DISTRIBUTED TO MULTIPLE PEOPLE, BUT IS MEANT FOR PERSONAL USE**.

### What does this mean?

The app is meant to be used by one person, you. Compiling the app and distributing it to others is dangerous, as your Plaid API secret and client ID should never be distributed to others, but are safe for you to have.

### Why does this matter?

Your Plaid API secret and client ID should never be distributd to others, but are safe for you to have for personal usage of this app. Production uses of the Plaid API would require a server backend to do the authenticated requests with the client ID and secret.

### Why didn't you use a server backend?

Since the app is for personal use and as a proof-of-concept, it didn't make sense to code an entire server to take care of that. Doing so also gives me the responsibility of storing user data properly, and makes this app harder to use and maintain. For personal use, this is the best way to go.

### What am I risking?

Someone could use your Plaid account (not your banking details, those are safe) to make malicious requests and get you blocked from using Plaid.

## Reporting Issues

If you find a bug or code issue, report it on the [issues page](/issues). Keep in mind that this is for actual bugs, **NOT BUILD ISSUES**. 

## Contributing

Feel free to contribute to the source code of Bank to make it something even better! Just try to adhere to the general coding style throughout, to make it as readable as possible.
