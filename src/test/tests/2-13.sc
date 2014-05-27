//@ test 70 0 0

function test2(n)
{
    n = n + 1;
    n = n + 1;
    n = n + 1;
    n = n + 1;
    n = n + 1;
    n = n + 1;
    n = n + 1;
    n = n + 1;
// no return,
// same as "return 0"
}


function test(n,m,k)
{
    n = n + 1;
    for (i=0;i<10000;i=i+1){
	test2(n);
    }
    return test2(n) + n;
}
