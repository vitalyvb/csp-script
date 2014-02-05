//@ test 8

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
    res = xmap2;
    return res[5];
}

