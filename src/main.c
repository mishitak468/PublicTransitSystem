#include <mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

void finish_with_error(MYSQL *con)
{
  fprintf(stderr, "%s\n", mysql_error(con));
  mysql_close(con);
  exit(1);
}

int main()
{
  srand(time(NULL)); // Seed for random delay simulation
  MYSQL *con = mysql_init(NULL);
  char *password = getenv("DB_PASS");

  if (mysql_real_connect(con, "localhost", "root", password, "TransitSystem", 0, NULL, 0) == NULL)
    finish_with_error(con);

  FILE *fp = fopen("data/raw_transit_data.csv", "r");
  char line[1024];
  fgets(line, sizeof(line), fp);

  while (fgets(line, sizeof(line), fp))
  {
    char *ptr = line;
    char *route = strtok_r(ptr, ",", &ptr);
    char *station = strtok_r(ptr, ",", &ptr);
    char *arrival = strtok_r(ptr, ",", &ptr);
    char *departure = strtok_r(ptr, ",", &ptr);
    if (departure)
      departure[strcspn(departure, "\r\n")] = 0;

    char arr_val[64], dep_val[64];

    // Advanced Logic: 20% chance to simulate a 2-minute "maintenance delay"
    if (arrival && strlen(arrival) > 0 && (rand() % 5 == 0))
    {
      sprintf(arr_val, "ADDTIME('%s', '00:02:00')", arrival);
    }
    else if (arrival && strlen(arrival) > 0)
    {
      sprintf(arr_val, "'%s'", arrival);
    }
    else
      strcpy(arr_val, "NULL");

    if (departure && strlen(departure) > 0)
      sprintf(dep_val, "'%s'", departure);
    else
      strcpy(dep_val, "NULL");

    char query[1024];
    // Note: Using the MySQL ADDTIME function directly in the INSERT for complexity
    sprintf(query, "INSERT INTO Schedule (route_id, station_id, arrival_time, departure_time) VALUES (%s, '%s', %s, %s)",
            route, station, arr_val, dep_val);

    mysql_query(con, query);
  }
  printf("Complex Ingestion Complete: Data sanitized with simulated delays.\n");
  mysql_close(con);
  fclose(fp);
  return 0;
}