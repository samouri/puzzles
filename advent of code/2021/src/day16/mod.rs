pub fn solve() {
    let contents = include_str!("./input.txt");
    println!("Part 1: {}", part_one(contents));
    println!("Part 2: {}", part_two(contents));
    println!("");
}

fn part_one(contents: &str) -> i64 {
    let bits = preprocess(contents);
    let packet = parse_packet(&bits);
    sum_versions(&packet)
}

fn part_two(contents: &str) -> i64 {
    let bits = preprocess(contents);
    let packet = parse_packet(&bits);
    eval(&packet)
}

fn preprocess(contents: &str) -> String {
    contents
        .chars()
        .map(char_to_bits)
        .fold(String::new(), |mut acc: String, s| {
            acc.push_str(&s);
            acc
        })
}

#[derive(Debug)]
enum Packet {
    Literal {
        version: i64,
        val: i64,
    },
    Operator {
        version: i64,
        packet_type: i64,
        subpackets: Vec<Packet>,
    },
}

fn eval(packet: &Packet) -> i64 {
    match packet {
        Packet::Literal { version: _, val } => *val,
        Packet::Operator {
            version: _,
            subpackets,
            packet_type,
        } => {
            match packet_type {
                // Sum type
                0 => subpackets.iter().map(eval).sum(),
                // Product
                1 => subpackets.iter().map(eval).product(),
                // Minimum
                2 => subpackets.iter().map(eval).min().unwrap(),
                // Max
                3 => subpackets.iter().map(eval).max().unwrap(),
                // Greater than
                5 => {
                    let l = eval(&subpackets[0]);
                    let r = eval(&subpackets[1]);
                    (l > r) as i64
                    // if l > r {
                    //     1
                    // } else {
                    //     0
                    // }
                }
                6 => {
                    let l = eval(&subpackets[0]);
                    let r = eval(&subpackets[1]);
                    (l < r) as i64
                }
                7 => {
                    let l = eval(&subpackets[0]);
                    let r = eval(&subpackets[1]);
                    (l == r) as i64
                }
                _ => todo!("Implement"),
            }
        }
    }
}

fn sum_versions(packet: &Packet) -> i64 {
    match packet {
        Packet::Literal { version, val: _ } => *version,
        Packet::Operator {
            version,
            subpackets,
            packet_type: _,
        } => version + subpackets.iter().map(sum_versions).sum::<i64>(),
    }
}

fn char_to_bits<'a>(c: char) -> String {
    format!("{:04b}", c.to_digit(16).unwrap())
}

fn parse_packet(bits: &str) -> Packet {
    parse_packet_helper(bits).0
}

fn parse_packet_helper(bits: &str) -> (Packet, usize) {
    let version = i64::from_str_radix(&bits[0..3], 2).unwrap();
    let packet_type = i64::from_str_radix(&bits[3..6], 2).unwrap();
    if packet_type == 4 {
        let mut num_str = String::new();
        let mut i = 6;
        loop {
            num_str.push_str(&bits[(i + 1)..(i + 5)]);
            i += 5;
            if bits.chars().nth(i - 5).unwrap() == '0' {
                break;
            }
        }
        let packet = Packet::Literal {
            version,
            val: i64::from_str_radix(&num_str, 2).unwrap(),
        };
        return (packet, i);
    }

    let mut subpackets: Vec<Packet> = Vec::new();
    let length_type = bits.chars().nth(6).unwrap();
    let mut i = 0;
    if length_type == '0' {
        let subpacket_bit_count = usize::from_str_radix(&bits[7..7 + 15], 2).unwrap();
        i = 7 + 15;
        while (i - (7 + 15)) < subpacket_bit_count {
            let (packet, step) = parse_packet_helper(&bits[i..]);
            subpackets.push(packet);
            i += step;
        }
    } else {
        let subpacket_count = usize::from_str_radix(&bits[7..7 + 11], 2).unwrap();
        i = 7 + 11;
        for _ in 0..subpacket_count {
            let (packet, step) = parse_packet_helper(&bits[i..]);
            subpackets.push(packet);
            i += step;
        }
    }

    let packet = Packet::Operator {
        version,
        subpackets,
        packet_type,
    };
    (packet, i)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn part_1() {
        assert_eq!(part_one("8A004A801A8002F478"), 16);
        assert_eq!(part_one("620080001611562C8802118E34"), 12);
        assert_eq!(part_one("C0015000016115A2E0802F182340"), 23);
        assert_eq!(part_one("A0016C880162017C3686B18A3D4780"), 31);
    }

    #[test]
    fn part_2() {
        assert_eq!(part_two("C200B40A82"), 3);
        assert_eq!(part_two("04005AC33890"), 54);
        assert_eq!(part_two("880086C3E88112"), 7);
        assert_eq!(part_two("CE00C43D881120"), 9);
    }
}
