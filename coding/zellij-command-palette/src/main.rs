#![forbid(unsafe_code)]

use std::collections::BTreeMap;
use zellij_tile::prelude::*;

#[derive(Default)]
struct Palette {
    query: String,
    selected: usize,
    access: Access,
}

#[derive(Clone, Copy, Default, Eq, PartialEq)]
enum Access {
    #[default]
    Pending,
    Granted,
    Denied,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
enum Command {
    NewTab,
    NewPane,
    NextTab,
    PreviousTab,
}

struct Entry {
    title: &'static str,
    alias: &'static str,
    command: Command,
}

const COMMANDS: &[Entry] = &[
    Entry {
        title: "New Tab",
        alias: "tab",
        command: Command::NewTab,
    },
    Entry {
        title: "New Pane",
        alias: "pane split",
        command: Command::NewPane,
    },
    Entry {
        title: "Next Tab",
        alias: "next",
        command: Command::NextTab,
    },
    Entry {
        title: "Previous Tab",
        alias: "previous prev",
        command: Command::PreviousTab,
    },
];

register_plugin!(Palette);

impl ZellijPlugin for Palette {
    fn load(&mut self, _configuration: BTreeMap<String, String>) {
        subscribe(&[EventType::Key, EventType::PermissionRequestResult]);
        request_permission(&[PermissionType::ChangeApplicationState]);
    }

    fn update(&mut self, event: Event) -> bool {
        match event {
            Event::PermissionRequestResult(PermissionStatus::Granted) => {
                self.access = Access::Granted;
                true
            }
            Event::PermissionRequestResult(PermissionStatus::Denied) => {
                self.access = Access::Denied;
                true
            }
            Event::Key(key) => self.handle_key(key),
            _ => false,
        }
    }

    fn render(&mut self, rows: usize, cols: usize) {
        print_text_with_coordinates(
            Text::new("Command Palette").color_all(2),
            0,
            0,
            Some(cols),
            None,
        );

        let query = format!("> {}_", self.query);
        print_text_with_coordinates(Text::new(query), 0, 1, Some(cols), None);

        match self.access {
            Access::Pending => {
                print_text_with_coordinates(
                    Text::new("Waiting for Zellij action permission"),
                    0,
                    3,
                    Some(cols),
                    None,
                );
            }
            Access::Denied => {
                print_text_with_coordinates(
                    Text::new("Permission denied; actions are disabled"),
                    0,
                    3,
                    Some(cols),
                    None,
                );
            }
            Access::Granted => self.render_commands(rows, cols),
        }

        print_text_with_coordinates(
            Text::new("Enter run  Esc clear/close  Ctrl-C close  Up/Down select").color_all(2),
            0,
            rows.saturating_sub(1),
            Some(cols),
            None,
        );
    }
}

impl Palette {
    fn handle_key(&mut self, key: KeyWithModifier) -> bool {
        match key.bare_key {
            BareKey::Esc if key.has_no_modifiers() => {
                if self.query.is_empty() {
                    close_self();
                } else {
                    self.query.clear();
                    self.selected = 0;
                }
                true
            }
            BareKey::Char('c') if key.has_modifiers(&[KeyModifier::Ctrl]) => {
                close_self();
                true
            }
            BareKey::Enter if key.has_no_modifiers() => {
                if self.access == Access::Granted {
                    if let Some(command) = command_at(&self.query, self.selected) {
                        self.execute(command);
                    }
                }
                true
            }
            BareKey::Backspace if key.has_no_modifiers() => {
                self.query.pop();
                self.selected = 0;
                true
            }
            BareKey::Up if key.has_no_modifiers() => {
                self.move_selection(false);
                true
            }
            BareKey::Down if key.has_no_modifiers() => {
                self.move_selection(true);
                true
            }
            BareKey::Char(character) if key.has_no_modifiers() && !character.is_control() => {
                self.query.push(character);
                self.selected = 0;
                true
            }
            _ => false,
        }
    }

    fn move_selection(&mut self, forward: bool) {
        self.selected = next_selection(self.selected, matching_command_count(&self.query), forward);
    }

    fn render_commands(&self, rows: usize, cols: usize) {
        let footer_row = rows.saturating_sub(1);
        for (visible_index, entry) in COMMANDS
            .iter()
            .filter(|entry| matches_query(&self.query, entry))
            .enumerate()
        {
            let row = 3 + visible_index;
            if row >= footer_row {
                break;
            }
            let text = if visible_index == self.selected {
                Text::new(entry.title).selected()
            } else {
                Text::new(entry.title)
            };
            print_text_with_coordinates(text, 0, row, Some(cols), None);
        }

        if matching_command_count(&self.query) == 0 && 3 < footer_row {
            print_text_with_coordinates(Text::new("No matching commands"), 0, 3, Some(cols), None);
        }
    }

    fn execute(&self, command: Command) {
        match command {
            Command::NewTab => {
                let _ = new_tab::<&str>(None, None);
            }
            Command::NewPane => new_pane(),
            Command::NextTab => go_to_next_tab(),
            Command::PreviousTab => go_to_previous_tab(),
        }
        close_self();
    }
}

fn next_selection(selected: usize, count: usize, forward: bool) -> usize {
    if count == 0 {
        0
    } else if forward {
        (selected + 1) % count
    } else if selected == 0 {
        count - 1
    } else {
        selected - 1
    }
}

fn matching_command_count(query: &str) -> usize {
    COMMANDS
        .iter()
        .filter(|entry| matches_query(query, entry))
        .count()
}

fn command_at(query: &str, index: usize) -> Option<Command> {
    COMMANDS
        .iter()
        .filter(|entry| matches_query(query, entry))
        .nth(index)
        .map(|entry| entry.command)
}

fn matches_query(query: &str, entry: &Entry) -> bool {
    fuzzy_subsequence(query, entry.title) || fuzzy_subsequence(query, entry.alias)
}

fn fuzzy_subsequence(query: &str, candidate: &str) -> bool {
    let mut candidate = candidate.chars();
    for needle in query.chars().filter(|character| !character.is_whitespace()) {
        let needle = needle.to_ascii_lowercase();
        if !candidate.any(|character| character.to_ascii_lowercase() == needle) {
            return false;
        }
    }
    true
}

#[cfg(test)]
mod tests {
    use super::{command_at, fuzzy_subsequence, matching_command_count, next_selection, Command};

    #[test]
    fn fuzzy_search_matches_case_insensitive_subsequences() {
        assert!(fuzzy_subsequence("nT", "New Tab"));
        assert!(fuzzy_subsequence("prv", "Previous Tab"));
        assert!(!fuzzy_subsequence("zz", "New Pane"));
    }

    #[test]
    fn empty_query_keeps_all_builtin_commands() {
        assert_eq!(matching_command_count(""), 4);
    }

    #[test]
    fn selected_command_uses_filtered_order_and_rejects_out_of_range() {
        assert_eq!(command_at("np", 0), Some(Command::NewPane));
        assert_eq!(command_at("np", 1), None);
    }

    #[test]
    fn selection_wraps_and_handles_no_matches() {
        assert_eq!(next_selection(3, 4, true), 0);
        assert_eq!(next_selection(0, 4, false), 3);
        assert_eq!(next_selection(0, 0, true), 0);
    }
}
