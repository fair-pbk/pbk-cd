compute_delta_bw <- function(age, bw, sex) {
    bw_nom <- compute_bw(age, sex)
    bw / bw_nom
}

compute_bw <- function(year, sex) {
  Delta_BW = 1
  mval = 12 * year
  if (sex == 1) {
    if (year <= 79) {
      m2 = mval * mval;
      m3 = m2 * mval;
      m4 = m3 * mval;
      m5 = m4 * mval;
      m6 = m5 * mval;
      m7 = m6 * mval;
      m8 = m7 * mval;
      m9 = m8 * mval;
      m10 = m9 * mval;
      m11 = m10 * mval;

      wbw = (3.938425 + 0.7518199 * mval - 0.02023793 * m2 + 0.0002921682 * m3
             - 2.06762e-06 * m4 + 8.469e-09 * m5 - 2.188427e-11 * m6
             + 3.699776e-14 * m7 - 4.099077e-17 * m8 + 2.874804e-20 * m9
             - 1.159732e-23 * m10 + 2.052602e-27 * m11) * Delta_BW;
    } else {
      wbw = 76 * Delta_BW;
    }
  } else if (sex == 2) {
    if (year <= 79) {
      m2 = mval * mval;
      m3 = m2 * mval;
      m4 = m3 * mval;
      m5 = m4 * mval;
      m6 = m5 * mval;
      m7 = m6 * mval;
      m8 = m7 * mval;
      m9 = m8 * mval;
      m10 = m9 * mval;
      m11 = m10 * mval;

      wbw = (3.932403 + 0.6866462 * mval - 0.01949911 * m2 + 0.00031311 * m3
             - 2.466654e-06 * m4 + 1.113217e-08 * m5 - 3.131402e-11 * m6
             + 5.693737e-14 * m7 - 6.706947e-17 * m8 + 4.947858e-20 * m9
             - 2.079251e-23 * m10 + 3.800367e-27 * m11) * Delta_BW;
    } else {
      wbw = 68 * Delta_BW;
    }
  }
}
