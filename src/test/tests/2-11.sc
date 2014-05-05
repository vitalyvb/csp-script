//@ test 60
//@ test 61
//@ test 62
//@ test 63
//@ test 64
//@ test 65
//@ test 66
//@ test 67

global g, g2;

map xmap {
    61 = 30,
    63 = 20,
    66 = 10,
}

function test(n)
{
    return xmap[n];
}
