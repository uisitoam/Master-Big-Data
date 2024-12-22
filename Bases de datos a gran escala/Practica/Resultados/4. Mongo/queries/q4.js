[
  {
    $match: {
      "torneo.nivel": "G",
      ronda: "F",
      "ganador.pais.codigo_iso2": "ES",
    },
  },

  {
    $group: {
      _id: "$ganador.id",
      jugador: {
        $first: {
          $concat: ["$ganador.nombre", " ", "$ganador.apellido"],
        },
      },
    },
  },

  {
    $lookup: {
      from: "partidos",
      let: { playerId: "$_id" },
      pipeline: [
        {
          $match: {
            $expr: {
              $or: [
                {
                  $eq: ["$ganador.id", "$$playerId"],
                },
                {
                  $eq: ["$perdedor.id", "$$playerId"],
                },
              ],
            },
          },
        },
      ],
      as: "all_matches",
    },
  },

  {
    $project: {
      _id: 0,
      jugador: 1,
      partidos: { $size: "$all_matches" },
      pcje_victorias: {
        $multiply: [
          {
            $divide: [
              {
                $size: {
                  $filter: {
                    input: "$all_matches",
                    cond: {
                      $eq: ["$$this.ganador.id", "$_id"],
                    },
                  },
                },
              },
              { $size: "$all_matches" },
            ],
          },
          100,
        ],
      },
      pcje_aces: {
        $multiply: [
          {
            $divide: [
              {
                $sum: {
                  $map: {
                    input: "$all_matches",
                    as: "match",
                    in: {
                      $cond: [
                        {
                          $eq: ["$$match.ganador.id", "$_id"],
                        },
                        "$$match.ganador.stats.aces",
                        "$$match.perdedor.stats.aces",
                      ],
                    },
                  },
                },
              },
              {
                $sum: {
                  $map: {
                    input: "$all_matches",
                    as: "match",
                    in: {
                      $cond: [
                        {
                          $eq: ["$$match.ganador.id", "$_id"],
                        },
                        "$$match.ganador.stats.puntos_servidos",
                        "$$match.perdedor.stats.puntos_servidos",
                      ],
                    },
                  },
                },
              },
            ],
          },
          100,
        ],
      },
      pcje_dobles_faltas: {
        $multiply: [
          {
            $divide: [
              {
                $sum: {
                  $map: {
                    input: "$all_matches",
                    as: "match",
                    in: {
                      $cond: [
                        {
                          $eq: ["$$match.ganador.id", "$_id"],
                        },
                        "$$match.ganador.stats.dobles_faltas",
                        "$$match.perdedor.stats.dobles_faltas",
                      ],
                    },
                  },
                },
              },
              {
                $sum: {
                  $map: {
                    input: "$all_matches",
                    as: "match",
                    in: {
                      $cond: [
                        {
                          $eq: ["$$match.ganador.id", "$_id"],
                        },
                        "$$match.ganador.stats.puntos_servidos",
                        "$$match.perdedor.stats.puntos_servidos",
                      ],
                    },
                  },
                },
              },
            ],
          },
          100,
        ],
      },
      pcje_servicios_ganados: {
        $multiply: [
          {
            $divide: [
              {
                $sum: {
                  $map: {
                    input: "$all_matches",
                    as: "match",
                    in: {
                      $cond: [
                        {
                          $eq: ["$$match.ganador.id", "$_id"],
                        },
                        {
                          $add: [
                            "$$match.ganador.stats.primeros_servicios_ganados",
                            "$$match.ganador.stats.segundos_servicios_ganados",
                          ],
                        },
                        {
                          $add: [
                            "$$match.perdedor.stats.primeros_servicios_ganados",
                            "$$match.perdedor.stats.segundos_servicios_ganados",
                          ],
                        },
                      ],
                    },
                  },
                },
              },
              {
                $sum: {
                  $map: {
                    input: "$all_matches",
                    as: "match",
                    in: {
                      $cond: [
                        {
                          $eq: ["$$match.ganador.id", "$_id"],
                        },
                        "$$match.ganador.stats.puntos_servidos",
                        "$$match.perdedor.stats.puntos_servidos",
                      ],
                    },
                  },
                },
              },
            ],
          },
          100,
        ],
      },
      pcje_restos_ganados: {
        $multiply: [
          {
            $divide: [
              {
                $sum: {
                  $map: {
                    input: "$all_matches",
                    as: "match",
                    in: {
                      $cond: [
                        {
                          $eq: ["$$match.ganador.id", "$_id"],
                        },
                        {
                          $subtract: [
                            "$$match.perdedor.stats.puntos_servidos",
                            {
                              $add: [
                                "$$match.perdedor.stats.primeros_servicios_ganados",
                                "$$match.perdedor.stats.segundos_servicios_ganados",
                              ],
                            },
                          ],
                        },
                        {
                          $subtract: [
                            "$$match.ganador.stats.puntos_servidos",
                            {
                              $add: [
                                "$$match.ganador.stats.primeros_servicios_ganados",
                                "$$match.ganador.stats.segundos_servicios_ganados",
                              ],
                            },
                          ],
                        },
                      ],
                    },
                  },
                },
              },
              {
                $sum: {
                  $map: {
                    input: "$all_matches",
                    as: "match",
                    in: {
                      $cond: [
                        {
                          $eq: ["$$match.ganador.id", "$_id"],
                        },
                        "$$match.perdedor.stats.puntos_servidos",
                        "$$match.ganador.stats.puntos_servidos",
                      ],
                    },
                  },
                },
              },
            ],
          },
          100,
        ],
      },
      pcje_breaks_salvados: {
        $multiply: [
          {
            $divide: [
              {
                $sum: {
                  $map: {
                    input: "$all_matches",
                    as: "match",
                    in: {
                      $cond: [
                        {
                          $eq: ["$$match.ganador.id", "$_id"],
                        },
                        "$$match.ganador.stats.breaks_salvados",
                        "$$match.perdedor.stats.breaks_salvados",
                      ],
                    },
                  },
                },
              },
              {
                $sum: {
                  $map: {
                    input: "$all_matches",
                    as: "match",
                    in: {
                      $cond: [
                        {
                          $eq: ["$$match.ganador.id", "$_id"],
                        },
                        "$$match.ganador.stats.breaks_afrontados",
                        "$$match.perdedor.stats.breaks_afrontados",
                      ],
                    },
                  },
                },
              },
            ],
          },
          100,
        ],
      },
      pcje_breaks_ganados: {
        $multiply: [
          {
            $divide: [
              {
                $sum: {
                  $map: {
                    input: "$all_matches",
                    as: "match",
                    in: {
                      $cond: [
                        {
                          $eq: ["$$match.ganador.id", "$_id"],
                        },
                        {
                          $subtract: [
                            "$$match.perdedor.stats.breaks_afrontados",
                            "$$match.perdedor.stats.breaks_salvados",
                          ],
                        },
                        {
                          $subtract: [
                            "$$match.ganador.stats.breaks_afrontados",
                            "$$match.ganador.stats.breaks_salvados",
                          ],
                        },
                      ],
                    },
                  },
                },
              },
              {
                $sum: {
                  $map: {
                    input: "$all_matches",
                    as: "match",
                    in: {
                      $cond: [
                        {
                          $eq: ["$$match.ganador.id", "$_id"],
                        },
                        "$$match.perdedor.stats.breaks_afrontados",
                        "$$match.ganador.stats.breaks_afrontados",
                      ],
                    },
                  },
                },
              },
            ],
          },
          100,
        ],
      },
    },
  },

  // Round all percentages to 1 decimal place
  {
    $project: {
      jugador: 1,
      partidos: 1,
      pcje_victorias: {
        $round: ["$pcje_victorias", 1],
      },
      pcje_aces: { $round: ["$pcje_aces", 1] },
      pcje_dobles_faltas: {
        $round: ["$pcje_dobles_faltas", 1],
      },
      pcje_servicios_ganados: {
        $round: ["$pcje_servicios_ganados", 1],
      },
      pcje_restos_ganados: {
        $round: ["$pcje_restos_ganados", 1],
      },
      pcje_breaks_salvados: {
        $round: ["$pcje_breaks_salvados", 1],
      },
      pcje_breaks_ganados: {
        $round: ["$pcje_breaks_ganados", 1],
      },
    },
  },
];
