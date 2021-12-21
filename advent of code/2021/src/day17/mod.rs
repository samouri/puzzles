use std::{
    cmp::max,
    collections::{HashMap, HashSet},
};

pub fn solve() {
    // target area: x=135..155, y=-102..-78
    let (x1, x2, y1, y2) = (135, 155, -102, -78);
    println!("Part 1: {}", part_one(y1, y2));
    println!("Part 2: {}", part_two(x1, x2, y1, y2));
}

fn part_one(y_start: i64, y_end: i64) -> i64 {
    let mut max_y = 0;
    for y_vel in 0..500 {
        let mut inner_max = 0;
        let mut intersected = false;
        let mut probe = Probe::new(0, y_vel);
        while probe.y >= y_end {
            probe.step();
            inner_max = max(probe.y, inner_max);
            if intersects(probe.y, (y_start, y_end)) {
                intersected = true;
            }
        }
        if intersected {
            max_y = max(inner_max, max_y);
        }
    }
    max_y
}

fn part_two(x_start: i64, x_end: i64, y_start: i64, y_end: i64) -> i64 {
    let mut x_step_cache: HashMap<i64, HashSet<i64>> = HashMap::new();
    let mut y_step_cache: HashMap<i64, HashSet<i64>> = HashMap::new();

    for vel in -5000..5000 {
        let mut probe = Probe::new(vel, vel);
        while probe.step < 5000 {
            probe.step();
            if intersects(probe.y, (y_start, y_end)) {
                let set = y_step_cache.entry(probe.step).or_insert(HashSet::new());
                set.insert(vel);
            }
            if intersects(probe.x, (x_start, x_end)) {
                let set = x_step_cache.entry(probe.step).or_insert(HashSet::new());
                set.insert(vel);
            }
        }
    }
    let mut permutations: HashSet<(i64, i64)> = HashSet::new();
    for (step, x_set) in x_step_cache {
        if let Some(y_set) = y_step_cache.get(&step) {
            for x in x_set {
                for &y in y_set {
                    permutations.insert((x, y));
                }
            }
        }
    }
    permutations.len() as i64
}

struct Probe {
    x: i64,
    y: i64,
    x_vel: i64,
    y_vel: i64,
    step: i64,
}

impl Probe {
    fn new(x_vel: i64, y_vel: i64) -> Self {
        Self {
            x: 0,
            y: 0,
            step: 0,
            x_vel,
            y_vel,
        }
    }

    fn step(&mut self) {
        self.step += 1;
        self.x += self.x_vel;
        if 0 < self.x_vel {
            self.x_vel -= 1;
        } else if self.x_vel < 0 {
            self.x_vel += 1;
        }

        self.y += self.y_vel;
        self.y_vel -= 1;
    }
}

fn intersects(x: i64, (x1, x2): (i64, i64)) -> bool {
    x1 <= x && x <= x2
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn part_1() {
        // target area: x=20..30, y=-10..-5
        assert_eq!(part_one(-10, -5), 45);
    }

    #[test]
    fn part_2() {
        // target area: x=20..30, y=-10..-5
        assert_eq!(part_two(20, 30, -10, -5), 112);
    }
}
