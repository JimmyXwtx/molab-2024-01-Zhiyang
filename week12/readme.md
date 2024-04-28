# Braille and the Development of a Vibration Dictionary for Deafblind Communication

## Introduction

This report outlines the development of a tactile communication system based on Braille, designed specifically for deafblind users. The system translates Braille characters into distinct vibration patterns, creating an accessible medium for conveying written information through touch. This project draws inspiration from Morse code, adapting its principles to suit tactile perception needs.

## What is Braille?

Braille is a tactile writing system used by people who are blind or visually impaired. It was invented by Louis Braille in the 19th century. Braille characters are small rectangular blocks called cells that contain tiny palpable bumps called raised dots. The number and arrangement of these dots distinguish one character from another. Each cell consists of six dot positions, organized in a 3x2 matrix.

### Braille Cell Structure

Here's how a Braille cell is structured:

- **Dot positions**: There are six dots in each cell, numbered from top to bottom and left to right.
- **Configurations**: Different configurations of raised dots within the cell represent different characters—letters, numbers, punctuation marks, and even musical, mathematical symbols.

## Development of a Vibration Dictionary

The vibration dictionary is an innovative adaptation of Braille, designed to translate its tactile language into vibration patterns that can be perceived through a device. This adaptation enables deafblind users to receive Braille characters as tactile feedback in the form of vibrations.

### Principles from Morse Code

Morse code, a method of encoding text characters as sequences of two different signal durations (dots and dashes), provides a foundation for creating a system of tactile feedback. Morse code's simplicity and effectiveness in non-visual communication inspired the development of a similar binary-like system for tactile sensations.

### Designing the Vibration Dictionary

The vibration dictionary employs a variety of vibration patterns to represent different Braille characters. Each pattern is a combination of short, long, double, and triple vibrations, interspersed with pauses to aid in distinguishing between characters.

#### Example Vibration Patterns

```json
[
    {"A": "S"},
    {"B": "S P S"},
    {"C": "S P L"},
    {"D": "L P S"},
    {"E": "L"},
    {"F": "D"},
    {"G": "T"},
    {"H": "S P S P S"},
    {"I": "S P L P S"},
    {"J": "L P S P L"},
    {"K": "D P S"},
    {"L": "T P L"},
    {"M": "D P D"},
    {"N": "T P T"},
    {"O": "L P L P L"},
    {"P": "S P D"},
    {"Q": "L P T"},
    {"R": "S P T P S"},
    {"S": "L P D P L"},
    {"T": "T P D"},
    {"U": "D P L"},
    {"V": "T P S"},
    {"W": "L P D"},
    {"X": "D P T"},
    {"Y": "T P D P T"},
    {"Z": "L P T P L"},
    {"1": "S"},
    {"2": "S P S"},
    {"3": "S P S P S"},
    {"4": "S P S P S P S"},
    {"5": "S P S P S P S P S"},
    {"6": "L P L"},
    {"7": "L P L P L"},
    {"8": "L P L P L P L"},
    {"9": "L P L P L P L P L"},
    {"0": "D P D"},
    {" ": "P P"}
]

