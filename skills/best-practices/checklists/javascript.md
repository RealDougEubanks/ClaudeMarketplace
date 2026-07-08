# JavaScript / TypeScript Checks

- [ ] `any` type used extensively — defeats TypeScript's purpose
- [ ] Missing `strict: true` in `tsconfig.json`
- [ ] `var` instead of `const`/`let`
- [ ] `==` instead of `===`
- [ ] `console.log` left in production code paths
- [ ] No ESLint or Prettier config
- [ ] Missing `.eslintrc` rules for security (`no-eval`, `no-implied-eval`)
- [ ] `require()` mixed with ES module `import`
- [ ] Callback-style async code instead of async/await
- [ ] Missing `package.json` `engines` field (Node version not specified)

## React (if detected)

- [ ] `useEffect` with missing or incorrect dependency array
- [ ] Missing `key` prop on list items
- [ ] State mutation instead of returning new state
- [ ] Large components doing data fetching + rendering + business logic (should split)
- [ ] No error boundaries around critical UI sections
- [ ] Prop drilling more than 2 levels deep (consider context or state management)
- [ ] Inline function definitions in JSX causing unnecessary re-renders
- [ ] Images without `alt` attributes (accessibility)

## Node/Express (if detected)

- [ ] Error handling middleware not registered last
- [ ] Missing `helmet` for HTTP security headers
- [ ] Missing rate limiting middleware
- [ ] `app.use(express.json({ limit: '50mb' }))` — unnecessarily large body limit
- [ ] Routes not grouped by resource with consistent naming
- [ ] Synchronous file operations (`fs.readFileSync`) in request handlers
