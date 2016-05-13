# Erlang Solution

Open the erlang repl `werl` on Windows, `erl` everywhere else. Change to the directory of the source file `opening_hours.erl` and then:

    c(opening_hours).
    opening_hours:run_tests().

If everything worked as planned you should see a simple output of `tests_ok`. If a test fails the system will give a `no match` error.

You can use your own data by creating a file called `openhours.txt` and entering in a list of tuples with 3 items, and closing with a full `.` stop. See below for an example.
`[{1,800,1600},{2,1000,1930}].`
