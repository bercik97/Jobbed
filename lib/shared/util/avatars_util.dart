class AvatarsUtil {
  static String getAvatarPathByLetter(String sex, String letter) {
    switch (letter.toUpperCase()) {
      case 'A': return 'images/letters/$sex/A.png';
      case 'B': return 'images/letters/$sex/B.png';
      case 'C': return 'images/letters/$sex/C.png';
      case 'D': return 'images/letters/$sex/D.png';
      case 'E': return 'images/letters/$sex/E.png';
      case 'F': return 'images/letters/$sex/F.png';
      case 'G': return 'images/letters/$sex/G.png';
      case 'H': return 'images/letters/$sex/H.png';
      case 'I': return 'images/letters/$sex/I.png';
      case 'J': return 'images/letters/$sex/J.png';
      case 'K': return 'images/letters/$sex/K.png';
      case 'L': return 'images/letters/$sex/L.png';
      case 'M': return 'images/letters/$sex/M.png';
      case 'N': return 'images/letters/$sex/N.png';
      case 'O': return 'images/letters/$sex/O.png';
      case 'P': return 'images/letters/$sex/P.png';
      case 'Q': return 'images/letters/$sex/Q.png';
      case 'R': return 'images/letters/$sex/R.png';
      case 'S': return 'images/letters/$sex/S.png';
      case 'T': return 'images/letters/$sex/T.png';
      case 'U': return 'images/letters/$sex/U.png';
      case 'V': return 'images/letters/$sex/V.png';
      case 'W': return 'images/letters/$sex/W.png';
      case 'X': return 'images/letters/$sex/X.png';
      case 'Y': return 'images/letters/$sex/Y.png';
      case 'Z': return 'images/letters/$sex/Z.png';
      case 'Ł': return 'images/letters/$sex/Ł.png';
      case 'Ż': return 'images/letters/$sex/Ż.png';
      default : return 'images/letters/$sex/unknown_letter.png';
    }
  }
}
