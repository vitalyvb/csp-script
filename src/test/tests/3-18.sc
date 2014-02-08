//@ main
//@ test 3 3
//@ test 1 3
//@ test 3 0

global s;

function main()
{
    s = new_array(4, 4);
    s[0] = new_array(4, 4);
    s[1] = new_array(4, 4);
    s[2] = new_array(4, 4);
    s[3] = new_array(4, 4);

    for (i=0;i<4;i=i+1)
	for (j=0;j<4;j=j+1){
	    t = s[i];
	    t[j] = i*256+j;
	}

    return 0;
}

function test(x,y)
{
    t = s[x];
    return t[y];
}
