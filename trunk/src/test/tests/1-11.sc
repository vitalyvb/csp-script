//@ test 8

function test(n)
{
    k = 2;
    r = 0;

    for (r=1;r<3;r=r+1) {
	r = r + 100;
	break;
    }

    return r;
}

