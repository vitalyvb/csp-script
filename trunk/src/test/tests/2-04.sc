//@ test

map xmap {
    1 = 5,
    2 = 6
}

function test()
{
    xmap[2] = xmap[1]+5;
    return xmap[2];
}

