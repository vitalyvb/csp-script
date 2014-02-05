//@ test 5
//@ test2

global g, g2;

map xmap {
    1 = 1,
    2 = 2,
    3 = 4,
    4 = 8,
    5 = 16,
    6 = 32,
    7 = 64
}

map xmap2 {
    5=6
}

function test(n)
{
    g = xmap;
    g2 = n;
}

function test2()
{
    return g[g2] + xmap2[g2];
}

