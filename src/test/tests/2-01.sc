//@ test

map xmap {
    1 = 5,
    2 = 6,
}

function test()
{
    i = xmap[1] + xmap[1+1];
    return i;
}

