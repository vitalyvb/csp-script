//@ test 8

function test(n)
{
    k = 2;
    r = 0;

    for (r=1;r<300;r=r+1) {
	r = r + 100;
	if (r < 300 ) {
	    r = r;
	    r = r;
	    r = r;
	    r = r;
	} else {
	    r = r;
	    r = r;
	    break;
	    r = r;
	    r = r;
	}
    }

    return r;
}

