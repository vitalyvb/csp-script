//@ main
//@ test

global s;

function main()
{
    s = new_array(4, 4);
    s[0] = new_array(4, 4);
    s[1] = new_array(4, 4);
    s[2] = new_array(4, 4);
    s[3] = new_array(4, 4);

    for (i=0;i<4;i=i+1)
	for (j=0;j<4;j=j+1)
	    s[i][j] = i*256+j;

    return 0;
}

function test()
{
    return -s[1][2]+s[3][3]+(s[1][0]*s[1][2])-(t=1);
}
