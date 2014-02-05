//@ test 8

global t;

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
    t = xmap;
    e = xmap2;
    return t[6] + e[5] + n;
}

