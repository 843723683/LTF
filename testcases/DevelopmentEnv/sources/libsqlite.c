#include <stdio.h>
#include <stdlib.h>
#include <sqlite3.h>

int main(void)
{
	sqlite3 *db = NULL;
	int rc;
	// 打开数据库
	rc = sqlite3_open("my.db",&db);
	if(rc)  // 不为0，打开失败
	{
		fprintf(stderr,"Can't open database:%s\n",sqlite3_errmsg(db));
		sqlite3_close(db);
		exit(0);
	}
	else
	{
		printf("open db success!\n");
		sqlite3_close(db);
	}

	return 0;
}
