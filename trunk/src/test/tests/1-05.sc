//@ test 8

function test(n)
{
    k = 2*2;
    if (k == 2){
	k = 77;
	k = k;
	k = k;
	k = k;
	k = k;
    } else {
	k = k + 2;
	k = k;
	k = k;
	k = k;
	k = k;
    }
    return k;
}

