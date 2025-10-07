import React, { useState, useEffect } from 'react';
import styled, { keyframes } from 'styled-components';
import { motion, AnimatePresence } from 'framer-motion';

const vhsGlitch = keyframes`
  0%, 100% { transform: translateX(0); }
  10% { transform: translateX(-2px); }
  20% { transform: translateX(2px); }
  30% { transform: translateX(-1px); }
  40% { transform: translateX(1px); }
  50% { transform: translateX(-2px); }
  60% { transform: translateX(2px); }
  70% { transform: translateX(-1px); }
  80% { transform: translateX(1px); }
  90% { transform: translateX(-1px); }
`;

const filmGrain = keyframes`
  0%, 100% { opacity: 0.05; }
  50% { opacity: 0.15; }
`;

const scanlines = keyframes`
  0% { transform: translateY(-100%); }
  100% { transform: translateY(100vh); }
`;

const Container = styled.div`
  height: 100%;
  background: #000;
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
`;

const VHSOverlay = styled.div`
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: 
    repeating-linear-gradient(
      0deg,
      transparent,
      transparent 2px,
      rgba(255,255,255,0.03) 2px,
      rgba(255,255,255,0.03) 4px
    );
  pointer-events: none;
  z-index: 5;
`;

const FilmGrain = styled.div`
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)' opacity='0.4'/%3E%3C/svg%3E");
  animation: ${filmGrain} 0.5s infinite;
  pointer-events: none;
  z-index: 3;
`;

const Scanline = styled.div`
  position: absolute;
  left: 0;
  right: 0;
  height: 2px;
  background: rgba(255,255,255,0.1);
  animation: ${scanlines} 3s linear infinite;
  z-index: 4;
`;

const VHSTimestamp = styled(motion.div)`
  position: absolute;
  top: 20px;
  left: 20px;
  color: #ff6b6b;
  font-family: 'Courier New', monospace;
  font-size: 14px;
  font-weight: bold;
  z-index: 10;
  text-shadow: 2px 2px 0px rgba(0,0,0,0.8);
  animation: ${vhsGlitch} 3s infinite;
`;

const VHSControls = styled(motion.div)`
  position: absolute;
  bottom: 20px;
  left: 20px;
  color: #ff6b6b;
  font-family: 'Courier New', monospace;
  font-size: 12px;
  z-index: 10;
  display: flex;
  gap: 15px;
  text-shadow: 2px 2px 0px rgba(0,0,0,0.8);
`;

const VideoFrame = styled(motion.div)`
  width: 280px;
  height: 200px;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
  border: 3px solid #333;
  border-radius: 8px;
  position: relative;
  overflow: hidden;
  box-shadow: 0 20px 40px rgba(0,0,0,0.6);
`;

const VideoContent = styled(motion.div)`
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  background: linear-gradient(45deg, #2d1b69 0%, #11998e 100%);
  position: relative;
`;

const FamilyScene = styled(motion.div)`
  display: flex;
  gap: 15px;
  margin-bottom: 20px;
`;

const Person = styled(motion.div)`
  font-size: 40px;
  animation: ${vhsGlitch} 4s infinite;
`;

const SceneText = styled(motion.div)`
  color: white;
  font-size: 14px;
  font-weight: 600;
  text-align: center;
  text-shadow: 2px 2px 4px rgba(0,0,0,0.8);
  animation: ${vhsGlitch} 5s infinite;
`;

const NostalgicText = styled(motion.h1)`
  color: #ff6b6b;
  font-size: 24px;
  font-weight: 800;
  text-align: center;
  margin: 30px 20px 20px 20px;
  text-shadow: 3px 3px 0px rgba(0,0,0,0.8);
  animation: ${vhsGlitch} 2s infinite;
  font-family: 'Arial Black', Arial, sans-serif;
  line-height: 1.2;
`;

const SubText = styled(motion.p)`
  color: rgba(255,255,255,0.9);
  font-size: 16px;
  text-align: center;
  margin: 0 20px 40px 20px;
  line-height: 1.4;
  text-shadow: 2px 2px 4px rgba(0,0,0,0.8);
`;

const ContinueButton = styled(motion.button)`
  background: #ff6b6b;
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 6px;
  font-size: 16px;
  font-weight: bold;
  cursor: pointer;
  box-shadow: 0 8px 25px rgba(255,107,107,0.3);
  transition: all 0.3s ease;
  
  &:hover {
    background: #ff5252;
    transform: translateY(-2px);
    box-shadow: 0 12px 35px rgba(255,107,107,0.4);
  }
`;

const scenes = [
  { people: ['👨‍👩‍👧‍👦', '🎂'], text: "Birthday party, 1994" },
  { people: ['👶', '🤱'], text: "Baby's first steps" },
  { people: ['🧑‍🎓', '👏'], text: "Graduation day" },
  { people: ['🎄', '🎁', '👨‍👩‍👧‍👦'], text: "Christmas morning" }
];

const NostalgicIntro = ({ onComplete }) => {
  const [currentScene, setCurrentScene] = useState(0);
  const [showContinue, setShowContinue] = useState(false);

  useEffect(() => {
    const sceneTimer = setInterval(() => {
      setCurrentScene(prev => {
        if (prev >= scenes.length - 1) {
          clearInterval(sceneTimer);
          setTimeout(() => setShowContinue(true), 1000);
          return prev;
        }
        return prev + 1;
      });
    }, 2000);

    return () => clearInterval(sceneTimer);
  }, []);

  return (
    <Container>
      <VHSOverlay />
      <FilmGrain />
      <Scanline />
      
      <VHSTimestamp
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.5 }}
      >
        ● REC 12:34 PM
      </VHSTimestamp>
      
      <VHSControls
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1 }}
      >
        <span>▶️ PLAY</span>
        <span>||</span>
        <span>⏹️</span>
        <span>⏪</span>
        <span>⏩</span>
      </VHSControls>

      <VideoFrame
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ duration: 0.8, delay: 0.3 }}
      >
        <VideoContent>
          <AnimatePresence mode="wait">
            <motion.div
              key={currentScene}
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 1.2 }}
              transition={{ duration: 0.6 }}
            >
              <FamilyScene>
                {scenes[currentScene].people.map((person, index) => (
                  <Person
                    key={index}
                    initial={{ y: 20, opacity: 0 }}
                    animate={{ y: 0, opacity: 1 }}
                    transition={{ delay: index * 0.2 }}
                  >
                    {person}
                  </Person>
                ))}
              </FamilyScene>
              <SceneText
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.8 }}
              >
                {scenes[currentScene].text}
              </SceneText>
            </motion.div>
          </AnimatePresence>
        </VideoContent>
      </VideoFrame>

      <NostalgicText
        initial={{ opacity: 0, y: 30 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 1.5 }}
      >
        Remember watching yourself<br />on the old home video camera?
      </NostalgicText>

      <SubText
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 2 }}
      >
        The grainy footage, the timestamps, seeing yourself from someone else's perspective...
        <br />Now recreate that magic with friends & family.
      </SubText>

      <AnimatePresence>
        {showContinue && (
          <ContinueButton
            onClick={onComplete}
            initial={{ opacity: 0, y: 30, scale: 0.8 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            transition={{ type: "spring", stiffness: 200 }}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            Let's Create Magic ✨
          </ContinueButton>
        )}
      </AnimatePresence>
    </Container>
  );
};

export default NostalgicIntro;