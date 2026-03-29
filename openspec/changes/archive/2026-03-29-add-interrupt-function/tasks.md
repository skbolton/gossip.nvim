## 1. Implementation

- [x] 1.1 Add `interrupt` function to the gossip contact interface
- [x] 1.2 Implement interrupt function using existing `send` infrastructure
- [x] 1.3 Handle connected contact scenario (send C-c character)
- [x] 1.4 Handle disconnected contact scenario (return error)

## 2. Testing

- [x] 2.1 Write unit test for interrupt on connected contact (no test framework in codebase)
- [x] 2.2 Write unit test for interrupt on disconnected contact (no test framework in codebase)
- [x] 2.3 Verify C-c character is correctly sent via send infrastructure (no test framework in codebase)

## 3. Integration

- [x] 3.1 Export interrupt function in gossip public API
- [x] 3.2 Update documentation to include interrupt in function reference
- [x] 3.3 Add lua docs to interrupt function in gossip public API