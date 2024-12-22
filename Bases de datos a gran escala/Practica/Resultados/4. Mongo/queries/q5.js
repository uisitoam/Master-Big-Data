[
  {
    $match: {
      "torneo.nombre": "Roland Garros",
      $expr: {
        $eq: [{ $year: { $toDate: "$torneo.fecha" } }, 2018],
      },
      ronda: "R128",
      $or: [
        {
          "ganador.nombre": "Rafael",
          "ganador.apellido": "Nadal",
        },
        {
          "perdedor.nombre": "Rafael",
          "perdedor.apellido": "Nadal",
        },
      ],
    },
  },

  {
    $project: {
      rival_id: {
        $cond: [
          {
            $and: [
              {
                $eq: ["$ganador.nombre", "Rafael"],
              },
              {
                $eq: ["$ganador.apellido", "Nadal"],
              },
            ],
          },
          "$perdedor.id",
          "$ganador.id",
        ],
      },
    },
  },

  {
    $lookup: {
      from: "partidos",
      localField: "rival_id",
      foreignField: "ganador.id",
      as: "partidos_rival",
    },
  },
  {
    $unwind: "$partidos_rival",
  },
  {
    $match: {
      $expr: {
        $eq: [
          {
            $year: {
              $toDate: "$partidos_rival.torneo.fecha",
            },
          },
          2018,
        ],
      },
    },
  },
  {
    $project: {
      _id: 0,
      jugador: {
        $concat: [
          "$partidos_rival.perdedor.nombre",
          " ",
          "$partidos_rival.perdedor.apellido",
        ],
      },
      pais: "$partidos_rival.perdedor.pais.codigo_iso2",
    },
  },
];
