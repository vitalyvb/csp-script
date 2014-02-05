//@ test

map xmap {
    1 = 5,
    2 = 6
}

function test()
{
    xmap[1*4] = 2+1;
    return 0;
}

