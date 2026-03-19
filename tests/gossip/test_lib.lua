local test = {}

local test_count = 0
local pass_count = 0
local fail_count = 0
local failures = {}

function test.describe(name, fn)
  print("\n  " .. name)
  fn()
end

function test.it(name, fn)
  test_count = test_count + 1
  local ok, err = pcall(fn)
  if ok then
    pass_count = pass_count + 1
    print("    ✓ " .. name)
  else
    fail_count = fail_count + 1
    table.insert(failures, { name = name, error = tostring(err) })
    print("    ✗ " .. name)
    print("      Error: " .. tostring(err))
  end
end

function test.assert.are.same(expected, actual)
  if expected ~= actual then
    error(string.format("Expected:\n%s\nActual:\n%s", vim.inspect(expected), vim.inspect(actual)))
  end
end

function test.assert.has_error(fn, expected_msg)
  local ok, err = pcall(fn)
  if ok then
    error("Expected function to throw an error, but it succeeded")
  end
  if expected_msg and not tostring(err):find(expected_msg, 1, true) then
    error(string.format("Expected error message containing '%s', got: %s", expected_msg, err))
  end
end

function test.assert.has_no_error(fn)
  local ok, err = pcall(fn)
  if not ok then
    error("Unexpected error: " .. tostring(err))
  end
end

function test.run_all()
  print("\n" .. string.rep("=", 60))
  print(string.format("Tests: %d | Passed: %d | Failed: %d", test_count, pass_count, fail_count))
  if fail_count > 0 then
    print("\nFailed tests:")
    for _, f in ipairs(failures) do
      print("  - " .. f.name .. ": " .. tostring(f.error))
    end
  end
  print(string.rep("=", 60) .. "\n")
  return fail_count == 0
end

return test
