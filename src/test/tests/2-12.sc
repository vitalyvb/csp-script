//@ test 1

function test2(n)
{
    n = n + 1;
    n = n + 1;
    n = n + 1;
    n = n + 1;
    n = n + 1;
    n = n + 1;
    n = n + 1;
    n = n + 1;
// no return,
// same as "return 0"
}


function test(n)
{
    n = n + 1;
    return test2(n);
}
