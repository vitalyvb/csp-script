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
	    continue;
	    r = r+10;
	    r = r+10;
	} else {
	    r = r;
	    r = r;
	    r = r;
	    r = r;
	}
    }

    return r;
}

