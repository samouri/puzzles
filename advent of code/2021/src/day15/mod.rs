use std::cmp::Ordering;
use std::collections::BinaryHeap;
use std::fs;

pub fn solve() {
    let path = "src/day15/input.txt";
    let file_content: String = fs::read_to_string(path).unwrap();

    let risk_map: Vec<Vec<usize>> = file_content
        .lines()
        .map(|l| {
            l.chars()
                .map(|c| c.to_digit(10).unwrap() as usize)
                .collect()
        })
        .collect();
    println!("Part 1: {:?}", djikstra(&risk_map).unwrap());

    // Most of the problem for part 2 is constructing the new array.
    let row_len = risk_map.len();
    let col_len = risk_map[0].len();
    let mut risk_map2: Vec<Vec<usize>> = vec![vec![0; col_len * 5]; row_len * 5];
    for row in 0..(row_len * 5) {
        for col in 0..(col_len * 5) {
            let add = (row / row_len) + (col / col_len);
            risk_map2[row][col] = risk_map[row % row_len][col % col_len] + add;
            if risk_map2[row][col] > 9 {
                risk_map2[row][col] -= 9
            }
        }
    }
    println!("Part 2: {:?}", djikstra(&risk_map2).unwrap());
}

fn djikstra(risk_map: &Vec<Vec<usize>>) -> Option<usize> {
    let mut acc: Vec<Vec<usize>> = risk_map
        .clone()
        .iter()
        .map(|v| v.iter().map(|_| usize::MAX).collect())
        .collect();

    let mut heap = BinaryHeap::new();
    acc[0][0] = 0;
    heap.push(State {
        cost: 0,
        position: (0, 0),
    });
    let goal = (risk_map.len() - 1, risk_map.last().unwrap().len() - 1);

    // Examine the frontier with lower cost nodes first (min-heap)
    while let Some(State { cost, position }) = heap.pop() {
        let (row, col) = position;
        if position == goal {
            return Some(cost);
        }

        // Important as we may have already found a better way
        if cost > acc[row][col] {
            continue;
        }

        // For each node we can reach, see if we can find a way with
        // a lower cost going through this node
        for nayb in neighbors(risk_map, row, col) {
            let next = State {
                cost: cost + risk_map[nayb.0][nayb.1],
                position: nayb,
            };

            // If so, add it to the frontier and continue
            if next.cost < acc[next.position.0][next.position.1] {
                heap.push(next);
                // Relaxation, we have now found a better way
                acc[next.position.0][next.position.1] = next.cost;
            }
        }
    }

    // Goal not reachable
    None
}

#[derive(Copy, Clone, Eq, PartialEq)]
struct State {
    cost: usize,
    position: (usize, usize),
}
impl Ord for State {
    fn cmp(&self, other: &Self) -> Ordering {
        // Notice that the we flip the ordering on costs (to make it min).
        // In case of a tie we compare positions - this step is necessary
        // to make implementations of `PartialEq` and `Ord` consistent.
        other
            .cost
            .cmp(&self.cost)
            .then_with(|| self.position.cmp(&other.position))
    }
}
impl PartialOrd for State {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

fn neighbors(risk_map: &Vec<Vec<usize>>, row: usize, col: usize) -> Vec<(usize, usize)> {
    let row_len = risk_map.len();
    let col_len = risk_map.last().unwrap().len();
    let mut naybs = Vec::new();

    if 0 < row {
        naybs.push((row - 1, col))
    }
    if row < row_len - 1 {
        naybs.push((row + 1, col))
    }
    if 0 < col {
        naybs.push((row, col - 1))
    }
    if col < col_len - 1 {
        naybs.push((row, col + 1))
    }

    return naybs;
}
