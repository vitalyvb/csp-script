//@ test1 10
//@ test2 5
//@ test3

global g;

function test1(n)
{
    g = n;
    return 0;
}

function test2(n)
{
    g = g + n;
    return 0;
}

function test3()
{
    return g;
}

