//@ test 8

function test(n)
{
    k = 2;
    r = 0;

    do {
	r = r + 1;
	r = r + 1;
	k = k - 1;
    } while (k > 1000);

    return r;
}

