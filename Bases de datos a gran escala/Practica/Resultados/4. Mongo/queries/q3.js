[
  {
    $match: {
      "torneo.nombre": "Roland Garros",
      $expr: {
        $eq: [{ $year: { $toDate: "$torneo.fecha" } }, 2018],
      },
      ronda: { $in: ["SF", "F"] },
    },
  },
  {
    $addFields: {
      resultado: {
        $reduce: {
          input: "$sets",
          initialValue: "",
          in: {
            $concat: [
              "$$value",
              {
                $cond: {
                  if: { $eq: ["$$value", ""] },
                  then: "",
                  else: " ",
                },
              },
              {
                $toString: "$$this.juegos_ganador",
              },
              "-",
              {
                $toString: "$$this.juegos_perdedor",
              },
              {
                $cond: {
                  if: {
                    $ne: ["$$this.puntos_tiebreak_perdedor", null],
                  },
                  then: {
                    $concat: [
                      "(",
                      {
                        $toString: "$$this.puntos_tiebreak_perdedor",
                      },
                      ")",
                    ],
                  },
                  else: "",
                },
              },
            ],
          },
        },
      },
    },
  },
  {
    $project: {
      _id: 0,
      ronda: 1,
      desenlace: 1,
      ganador: {
        $concat: ["$ganador.nombre", " ", "$ganador.apellido"],
      },
      perdedor: {
        $concat: ["$perdedor.nombre", " ", "$perdedor.apellido"],
      },
      resultado: 1,
    },
  },
];
