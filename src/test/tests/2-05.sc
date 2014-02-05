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

function test(n)
{
    res = 0;
    for (i=1;i<8;i=i+1){
	res = res + xmap[i];
    }
    return res + n;
}

