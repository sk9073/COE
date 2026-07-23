## Key Takeaways & Core Concepts

1. Why Code Rots: The Four Symptoms
When software isn't designed for change, small feature additions lead to four primary symptoms
- Rigidity: A single small change triggers a cascading wave of updates across the system
- Fragility: Changes cause unexpected breakage in seemingly unrelated areas
- Immobility: Code cannot be extracted for reuse, forcing copy-paste duplication
- Viscosity: Doing the right thing is hard, so developers resort to messy hacks

2. The SOLID Principles in Ruby
- Single Responsibility (SRP): A class should have only one reason to change.
- Open/Closed (OCP): Code should be open for extension but closed for modification.
- Liskov Substitution (LSP): Subclasses must be transparently usable in place of their superclass.
- Interface Segregation (ISP): Dynamic languages naturally satisfy ISP through duck typing, rendering explicit interface segregation unnecessary.
- Dependency Inversion (DIP): High-level modules should depend on abstractions, not concrete details.

3. Managing Dependencies & Direction
The primary enemy of maintainable code is unmanaged dependencies:
- Depend on the Stable: Always make highly changeable classes depend on objects that change less frequently, never the reverse.
- Use Dependency Injection: Pass dependencies into initializers (with sensible defaults) rather than hardcoding class instantiations inside methods.
- Pass Parameter Hashes: Replace positional arguments with option hashes to remove ordering dependencies between callers and callees.

4. Step-by-Step Refactoring Workflow
Sandi demonstrates her refactoring process using a sample PatentJob class (which initially downloads FTP files, parses them, and updates a database):

- Extract Responsibilities: Separate file downloading logic into a dedicated FTPDownloader class and inject it into PatentJob.
- Extract Configuration: Isolate volatile configuration values (e.g., credentials, file paths) into a dynamic Config object.
- Generalize Components: Remove hardcoded class names so FTPDownloader can download any file for any given configuration.
- Dynamic Execution: Store class names inside external YAML configuration files to fulfill unknown future requirements without modifying existing classes.

5. The Green Refactor Checklist
Every time your test suite turns green, evaluate your code with four questions before moving on:
- Is it DRY?
- Does the class have only one responsibility?
- Does everything in the class change at the same rate?
- Does it depend on things that change less often than it does?

6. Why Applications Become "Messes"
- The Trajectory of Code Quality: Applications start out clean and joyful, but over time, feature additions and changing requirements turn them into "hostages of their design".
- Coupling & Knowledge: The mess is driven by unmanaged dependencies—specifically, when objects know too much about other objects outside of their direct purpose.
- Omega Messes: A "mess" (messy code) at the absolute end of a dependency chain that has no dependents and no external dependencies. Because no other part of the system relies on it, an Omega Mess can safely be left alone or hidden until change is strictly necessary.

7. Concrete vs. Abstract Code
- Concrete Code: Easy to read and understand at first glance, but expensive and fragile to change over time.
- Abstract Code: Harder to grasp initially, but far cheaper and safer to extend or modify.
- Design Mindset: Shift from "Where should I put this code?" to "What message should I send?"

8. The 4-Quadrant Knowledge Plot
Sandi introduces a matrix to evaluate where any piece of knowledge belongs in an object-oriented codebase.

| Knowledge Context      | Stable (Unlikely to change)                                       | Unstable (Likely to change)                               |
|------------------------|-------------------------------------------------------------------|-----------------------------------------------------------|
| Inside Object Purpose  | Public API: Expose publicly to collaborators.                     | Private Behavior: Hide strictly behind the public API.    |
| Outside Object Purpose | Stable Dependencies: Minimize, but keep to allow collaboration.   | Unstable Dependencies: Move immediately out of the class. |

9. The Unit Testing Grid

| Message Origin| Query (No Side Effects)| Command (Has Side Effects) |
|--|--|--|
| Incoming	| Assert Result / Return Value Test the public interface, never the implementation | Assert Direct Public Side Effect Verify state changes on the receiving object. |
|Sent to Self | Do Not Test Private queries are covered through public interface tests.| Do Not Test Testing private commands leads to over-specification.|
| Outgoing	| Do Not Test Receiving object is solely responsible for its own state. | Set Expectation / Mock Verify that the message was sent to the nearest edge. |

When an object sends a command message to a collaborator that triggers a side effect (e.g., observer.changed), test that the message was sent using a mock/expectation at the nearest boundary rather than testing the distant side effect

10. Duplication vs. The Wrong Abstraction
- Duplication is cheap; the wrong abstraction is expensive.
- Novices are taught DRY (Don't Repeat Yourself) early because duplication is easy to recognize. However, forcing an abstraction too early creates messy dependencies that are difficult to undo later.
- Tolerating temporary code duplication while gathering more domain information leads to cleaner long-term designs

"Make the change easy (this may be hard), then make the easy change."

11. Composition over Inheritance

- Inheritance Is for Specialization, Not Code Sharing: Using inheritance to share behavior across variants leads to a combinatorial explosion when requirements mix (e.g., trying to combine RandomHouse and EchoHouse)
- There Is Never Just One Specialization: When you discover a variant, you actually have two variants: the new behavior and the implicit "default" behavior
- Isolate & Inject Roles: Identify what varies, name the concept, define a duck-type role, and inject collaborator objects using dependency injection

12. The 5 Categories of Code Smells

| Category |	Description | 	Primary Examples |
| -- | -- | -- |
| Bloaters |	Code, methods, or classes that grow unnecessarily large .|	Long Method, Large Class, Primitive Obsession, Data Clump .|
| Tool Abusers |	Misusing Object-Oriented language features .|	Switch Statements, Refused Bequest, Temporary Field .|
| Change Preventers |	Code structures that make future updates difficult or costly .|	Divergent Change, Shotgun Surgery, Parallel Inheritance .|
| Dispensables |	Unnecessary code that should be removed .|	Lazy Class, Data Class, Speculative Generality .|
| Couplers |	Tightly binding objects together so they cannot be reused independently .|	Feature Envy, Inappropriate Intimacy, Message Chains .|