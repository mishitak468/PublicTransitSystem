#include <stdio.h>
#include <stdlib.h>
#include <libpq-fe.h>
#include <string.h>

int main()
{
  const char *conninfo = "host=localhost dbname=TransitSystem user=postgres password=password";
  PGconn *conn = PQconnectdb(conninfo);

  if (PQstatus(conn) != CONNECTION_OK)
  {
    fprintf(stderr, "Connection failed: %s", PQerrorMessage(conn));
    PQfinish(conn);
    return 1;
  }

  FILE *fp = fopen("data/raw_transit_data.csv", "r");
  char line[1024], original_line[1024];
  fgets(line, sizeof(line), fp); // Skip header

  int success_count = 0, error_count = 0;

  while (fgets(line, sizeof(line), fp))
  {
    strcpy(original_line, line); // Keep a copy for error logging
    char *route = strtok(line, ",");
    char *station = strtok(NULL, ",");
    char *scheduled = strtok(NULL, ",");
    char *actual = strtok(NULL, ",");

    // VALIDATION LOGIC
    if (atoi(station) <= 0)
    {
      char err_query[2048];
      sprintf(err_query, "INSERT INTO ingestion_errors (raw_line_content, error_reason) VALUES ('%s', 'Invalid Station ID')", original_line);
      PQclear(PQexec(conn, err_query));
      error_count++;
      continue;
    }

    // SUCCESSFUL INSERT
    char query[1024];
    sprintf(query, "INSERT INTO schedules (route_id, station_id, scheduled, actual) VALUES (%s, %s, '%s', '%s')",
            route, station, scheduled, actual);
    PQclear(PQexec(conn, query));
    success_count++;

    if ((success_count + error_count) % 5000 == 0)
    {
      printf("\rProcessing: [%d / 100000]", success_count + error_count);
      fflush(stdout);
    }
  }

  printf("\nProcess Complete!\n- Successfully Ingested: %d\n- Errors Logged: %d\n", success_count, error_count);
  fclose(fp);
  PQfinish(conn);
  return 0;
}