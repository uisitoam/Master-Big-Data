[
  {
    $match: {
      "ganador.apellido": "Federer",
      "torneo.nivel": { $in: ["G", "M"] },
      ronda: "F",
    },
  },
  {
    $addFields: {
      año: {
        $year: { $toDate: "$torneo.fecha" },
      },
    },
  },
  {
    $group: {
      _id: "$año",
      total: { $sum: 1 },
      torneos: {
        $push: {
          nombre: "$torneo.nombre",
          fecha: { $toDate: "$torneo.fecha" },
        },
      },
    },
  },
  {
    $addFields: {
      torneos: {
        $sortArray: {
          input: "$torneos",
          sortBy: { fecha: 1 },
        },
      },
    },
  },
  {
    $project: {
      _id: 0,
      año: "$_id",
      total: "$total",

      torneos: {
        $reduce: {
          input: "$torneos.nombre",
          initialValue: "",
          in: {
            $cond: {
              if: { $eq: ["$$value", ""] },
              then: "$$this",
              else: {
                $concat: ["$$value", ", ", "$$this"],
              },
            },
          },
        },
      },
    },
  },
  {
    $sort: { año: 1 },
  },
];
