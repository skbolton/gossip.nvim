## 1. Implement Contact.send() in contact.lua

- [x] 1.1 Create new Contact.send(contact, keys) function in lua/gossip/contact.lua
- [x] 1.2 Implement keys parameter handling (string or table)
- [x] 1.3 Preserve existing pane creation delay logic (150ms defer)
- [x] 1.4 Remove old Contact.chat() function
- [x] 1.5 Remove old Contact.send_keys() function

## 2. Update module-level exports in init.lua

- [x] 2.1 Add gossip.send(contact, keys) export pointing to Contact.send()
- [x] 2.2 Remove gossip.chat() export
- [x] 2.3 Remove gossip.send_keys() export

## 3. Add documentation

- [x] 3.1 Add LuaDoc comments and typespecs above Contact.send() in contact.lua
- [x] 3.2 Add LuaDoc comments and typespecs above gossip.send() in init.lua

## 4. Verify implementation

- [x] 4.1 Test Contact.send() with single string
- [x] 4.2 Test Contact.send() with table of keys
- [x] 4.3 Test gossip.send() at module level
- [x] 4.4 Verify old functions no longer exist
