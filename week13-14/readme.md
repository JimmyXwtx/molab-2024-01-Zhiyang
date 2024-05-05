# FeelIt: Empowering the Deafblind Community

## Overview

**FeelIt** is a groundbreaking application meticulously designed by Zhiyang Wang under the guidance of instructor JHT. The app is tailored for the deafblind community, enabling users to experience and interpret their surroundings in a novel way. By utilizing a simple double-tap gesture on their smartphone's screen, users can activate the app's camera to capture the environment. This visual information is then translated into tactile feedback through vibrations in Morse code, allowing users to "feel" what is directly in front of them.

## Project Genesis and Development

### Inspiration and Research

The inspiration for **FeelIt** came from a deep understanding of the challenges faced by the deafblind community in interacting with their environment. Recognizing the limitations of existing communication tools, Zhiyang Wang embarked on a journey to design a solution that would transcend these barriers.

#### Key Research Components

Extensive research was conducted to explore and evaluate various tactile communication systems, such as Braille and Moon type. The findings from this research laid the groundwork for developing a bespoke vibration system that employs Morse code, chosen for its simplicity and global recognition.

- [Research on Deafblind Communication Tools](https://github.com/JimmyXwtx/molab-2024-01-Zhiyang/tree/main/week11)
- [Braille and the Development of a Vibration Dictionary for Deafblind Communication](https://github.com/JimmyXwtx/molab-2024-01-Zhiyang/tree/main/week12)

### Development Challenges

The primary challenge in the development of FeelIt was crafting a vibration system that was not only effective but also easy to learn for the deafblind community. Initial testing phases revealed significant insights into the learning curves associated with new tactile systems. These insights were crucial in pivoting the project towards the implementation of Morse code.

## Technical Architecture

### System Components

1. **Optical Character Recognition (OCR):** The OCR component is crucial for capturing text from images captured by the app's camera. This text forms the basis of the tactile feedback provided to the user.
2. **AI-Powered Image Analysis:** Advanced artificial intelligence models are utilized to analyze and interpret the context of the captured images, providing a layered understanding of the environment.
3. **Vibration Translation:** The final step involves translating the analyzed text and context into Morse code, which is then communicated to the user through the smartphone's vibration system.

### Integration and Optimization

Current efforts are focused on refining the image upload and analysis process, which has been challenging. The project leverages cutting-edge AI research, including Salesforce's BLIP model (Bootstrapping Language-Image Pre-training), to enhance the clarity and reliability of the transcription results.

## Future Directions

- **Enhancing AI Responsiveness:** Ongoing development aims to improve the AI's capability to provide faster and more accurate interpretations of both textual and contextual elements within images.
- **User Experience Optimization:** We are continuously seeking ways to make the user interface more intuitive and accessible for the deafblind community.

## Acknowledgements

This project would not have been possible without the dedicated guidance of instructor JHT, whose expertise and insights have been invaluable throughout the development process.

## Conclusion

**FeelIt** represents a significant technological advancement in the field of assistive technologies for the deafblind. By combining innovative research with practical application, Zhiyang Wang has developed an essential tool that promises to enhance the autonomy and interaction capabilities of the deafblind community.
