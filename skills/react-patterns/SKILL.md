# React Patterns

> Best practices for React development: functional components, hooks, state management, performance, and accessibility.

## Component Rules

1. **Always use functional components** — never class components for new code
2. **One component per file** — name the file the same as the component (PascalCase)
3. **Export components as named exports** — default exports only for pages/routes
4. **Colocate related files** — keep `Component.tsx`, `Component.test.tsx`, and `Component.module.css` together
5. **Props interface above the component** — name it `ComponentNameProps`

```tsx
// Good
interface UserCardProps {
  user: User;
  onSelect: (id: string) => void;
  variant?: "compact" | "full";
}

export function UserCard({ user, onSelect, variant = "full" }: UserCardProps) {
  return ( /* ... */ );
}
```

```tsx
// Bad — default export, inline props, class component
export default class UserCard extends React.Component<{user: any}> { /* ... */ }
```

## Hooks Patterns

### Custom Hooks

1. **Prefix with `use`** — `useAuth`, `useDebounce`, `useLocalStorage`
2. **Extract shared logic into custom hooks** — if two components share stateful logic, extract it
3. **Return tuples for simple hooks, objects for complex ones**

```tsx
// Simple: return tuple
function useToggle(initial = false): [boolean, () => void] {
  const [value, setValue] = useState(initial);
  const toggle = useCallback(() => setValue((v) => !v), []);
  return [value, toggle];
}

// Complex: return object
function useApi<T>(url: string) {
  const [data, setData] = useState<T | null>(null);
  const [error, setError] = useState<Error | null>(null);
  const [loading, setLoading] = useState(true);
  // ... fetch logic
  return { data, error, loading, refetch };
}
```

### Hook Rules

1. **Never call hooks conditionally** — all hooks must run on every render
2. **Use `useCallback` for functions passed to children** — prevents unnecessary re-renders
3. **Use `useMemo` only for expensive computations** — don't wrap everything
4. **Prefer `useReducer` over `useState` when state transitions are complex**

### useEffect Guidelines

1. **Always specify dependencies** — never use `// eslint-disable-next-line`
2. **Return a cleanup function for subscriptions, timers, and listeners**
3. **Avoid setting state in useEffect when you can derive it** — computed values don't need effects

```tsx
// Bad — unnecessary effect
const [fullName, setFullName] = useState("");
useEffect(() => {
  setFullName(`${firstName} ${lastName}`);
}, [firstName, lastName]);

// Good — derived value
const fullName = `${firstName} ${lastName}`;
```

## State Management Tiers

Use the simplest tier that solves the problem:

| Tier | Tool | When to Use |
|------|------|-------------|
| 1. Local state | `useState`, `useReducer` | Single component state |
| 2. Lifted state | Props, composition | Shared between parent/child |
| 3. Context | `createContext` + `useContext` | Theme, auth, locale — rarely changes |
| 4. URL state | Search params, path params | Filters, pagination, navigation state |
| 5. Server state | React Query / SWR | API data, caching, synchronization |
| 6. Global store | Zustand / Redux Toolkit | Complex client state across many components |

### Context Guidelines

1. **Split contexts by domain** — `AuthContext`, `ThemeContext`, not `AppContext`
2. **Keep context values stable** — use `useMemo` on the provider value
3. **Don't put frequently changing values in context** — it re-renders all consumers

```tsx
// Good — stable context value
function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);

  const value = useMemo(() => ({ user, setUser }), [user]);

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}
```

## Performance

1. **Use React.lazy + Suspense for route-level code splitting**
2. **Memoize expensive list items with `React.memo`** — include a custom comparator if props are objects
3. **Virtualize long lists** — use `react-window` or `@tanstack/virtual` for 100+ items
4. **Avoid anonymous functions in JSX when passing to memoized children**
5. **Use `key` correctly** — stable, unique identifiers, never array index for dynamic lists

```tsx
// Good — code splitting
const Dashboard = lazy(() => import("./pages/Dashboard"));

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
      </Routes>
    </Suspense>
  );
}
```

## Accessibility

1. **Use semantic HTML** — `<button>` not `<div onClick>`, `<nav>` not `<div className="nav">`
2. **All images need alt text** — empty `alt=""` for decorative images
3. **Form inputs need labels** — use `<label htmlFor>` or `aria-label`
4. **Manage focus on route changes** — focus the main heading after navigation
5. **Support keyboard navigation** — all interactive elements must be reachable via Tab
6. **Use ARIA attributes when semantic HTML is insufficient** — `aria-expanded`, `aria-live`, `role`

```tsx
// Good — accessible modal
function Modal({ isOpen, onClose, title, children }: ModalProps) {
  const closeRef = useRef<HTMLButtonElement>(null);

  useEffect(() => {
    if (isOpen) closeRef.current?.focus();
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div role="dialog" aria-modal="true" aria-labelledby="modal-title">
      <h2 id="modal-title">{title}</h2>
      {children}
      <button ref={closeRef} onClick={onClose}>
        Close
      </button>
    </div>
  );
}
```

## Error Boundaries

1. **Wrap route-level components in error boundaries**
2. **Provide a meaningful fallback UI** — not just "Something went wrong"
3. **Log errors to your monitoring service in the boundary**

```tsx
import { ErrorBoundary } from "react-error-boundary";

function ErrorFallback({ error, resetErrorBoundary }: FallbackProps) {
  return (
    <div role="alert">
      <h2>Something went wrong</h2>
      <pre>{error.message}</pre>
      <button onClick={resetErrorBoundary}>Try again</button>
    </div>
  );
}

// Usage
<ErrorBoundary FallbackComponent={ErrorFallback}>
  <Dashboard />
</ErrorBoundary>
```

## Anti-patterns

- **Prop drilling more than 2 levels** — use composition or context instead
- **Giant useEffect blocks** — split into multiple focused effects
- **Storing derived state** — compute it during render
- **Premature optimization** — profile before adding `useMemo`/`useCallback` everywhere
- **String-based refs** — use `useRef` only
- **Direct DOM manipulation** — use refs only when React APIs are insufficient
