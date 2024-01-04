import pandas as pd
from utils.database_utils import read_sql

# round1 = [
#     {"matchup": (player1, player2), "winner": None},
#     {"matchup": (player3, player4), "winner": None},
# ]

SELECT
    name,
    jsonb_object_agg(week, COALESCE(points, 'bye')) AS playoff_data
FROM
    (
        SELECT
            va.name,
            vm.week,
            SUM(vm.playoff_points) AS points
        FROM
            staging.vw_analytics va
        LEFT JOIN
            vw_matchups vm
        ON
            va.name = vm.name
        WHERE
            vm.is_playoffs = true
        GROUP BY
            va.name, vm.week
    ) AS subquery
GROUP BY
    name
ORDER BY
    name;