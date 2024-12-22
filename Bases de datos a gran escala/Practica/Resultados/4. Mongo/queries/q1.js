[
  {
    $match: {
      "torneo.nombre": "Wimbledon",
      ronda: "F",
    },
  },
  {
    $project: {
      _id: 0,
      nombre: "$ganador.nombre",
      apellido: "$ganador.apellido",
      año: {
        $year: {
          $toDate: "$torneo.fecha",
        },
      },
    },
  },
  {
    $sort: {
      año: 1,
    },
  },
];
