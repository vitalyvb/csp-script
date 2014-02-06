//@ test 7
//@ test2

global g, g2;

map xmap {
    $FALSE = $TRUE,
//    $TRUE = $FALSE,
    $TEST7 = $TEST9,
    $TEST9 = $TEST7,
}

function test(n)
{
    g = xmap;
    g2 = n;
}

function test2()
{
    return g[g2] + xmap[$FALSE];
}

