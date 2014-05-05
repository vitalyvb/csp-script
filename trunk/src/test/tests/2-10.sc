//@ test 52
//@ test 53
//@ test 54
//@ test 55
//@ test 56
//@ test 57
//@ test 58

global g, g2;

map xmap {
    0x39 = 0x2a,
    0x35 = 0x29,
}

function test(n)
{
    return xmap[n];
}
