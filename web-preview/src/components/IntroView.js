import React, { useEffect, useState } from 'react';
import styled, { keyframes } from 'styled-components';
import { motion } from 'framer-motion';

const filmGrain = keyframes`
  0%, 100% { transform: translate(0, 0) rotate(0deg); }
  10% { transform: translate(-5%, -5%) rotate(0.5deg); }
  20% { transform: translate(-10%, 5%) rotate(-0.5deg); }
  30% { transform: translate(5%, -10%) rotate(0.5deg); }
  40% { transform: translate(-5%, 15%) rotate(-0.5deg); }
  50% { transform: translate(-10%, 5%) rotate(0.5deg); }
  60% { transform: translate(15%, 0%) rotate(-0.5deg); }
  70% { transform: translate(0%, 15%) rotate(0.5deg); }
  80% { transform: translate(-15%, 10%) rotate(-0.5deg); }
  90% { transform: translate(10%, 5%) rotate(0.5deg); }
`;

const Container = styled.div`
  height: 100%;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  text-align: center;
  position: relative;
  overflow: hidden;
`;

const FilmGrainOverlay = styled.div`
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: 
    radial-gradient(circle at 20% 50%, transparent 20%, rgba(255,255,255,0.01) 21%, rgba(255,255,255,0.01) 34%, transparent 35%, transparent),
    linear-gradient(0deg, transparent 24%, rgba(255,255,255,0.02) 25%, rgba(255,255,255,0.02) 26%, transparent 27%, transparent 74%, rgba(255,255,255,0.02) 75%, rgba(255,255,255,0.02) 76%, transparent 77%, transparent);
  animation: ${filmGrain} 8s steps(10) infinite;
  pointer-events: none;
  mix-blend-mode: overlay;
`;

const VintageFrame = styled.div`
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  border: 3px solid rgba(255, 215, 0, 0.1);
  border-radius: 8px;
  box-shadow: 
    inset 0 0 50px rgba(0, 0, 0, 0.3),
    inset 0 0 100px rgba(0, 0, 0, 0.1);
  pointer-events: none;
`;

const ContentWrapper = styled(motion.div)`
  z-index: 2;
  max-width: 320px;
  padding: 0 20px;
`;

const LogoContainer = styled(motion.div)`
  position: relative;
  margin-bottom: 40px;
`;

const Logo = styled(motion.div)`
  font-size: 80px;
  position: relative;
  filter: drop-shadow(0 8px 16px rgba(0,0,0,0.4));
`;

const LogoGlow = styled.div`
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 120px;
  height: 120px;
  background: radial-gradient(circle, rgba(255, 215, 0, 0.2) 0%, transparent 70%);
  border-radius: 50%;
  filter: blur(20px);
`;

const Title = styled(motion.h1)`
  color: #fff;
  font-size: 36px;
  font-weight: 800;
  margin-bottom: 20px;
  line-height: 1.1;
  letter-spacing: -1.5px;
  text-shadow: 0 4px 8px rgba(0,0,0,0.5);
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
`;

const Subtitle = styled(motion.p)`
  color: rgba(255, 255, 255, 0.85);
  font-size: 18px;
  line-height: 1.4;
  margin-bottom: 50px;
  font-weight: 400;
  text-shadow: 0 2px 4px rgba(0,0,0,0.3);
`;

const GetStartedButton = styled(motion.button)`
  background: linear-gradient(135deg, #FF6B6B 0%, #FF8E53 100%);
  border: none;
  color: white;
  border-radius: 30px;
  padding: 18px 40px;
  font-size: 18px;
  font-weight: 700;
  cursor: pointer;
  box-shadow: 
    0 8px 32px rgba(255, 107, 107, 0.4),
    0 2px 8px rgba(0, 0, 0, 0.2);
  transition: all 0.3s ease;
  letter-spacing: 0.5px;
  
  &:hover {
    transform: translateY(-2px);
    box-shadow: 
      0 12px 40px rgba(255, 107, 107, 0.5),
      0 4px 12px rgba(0, 0, 0, 0.3);
  }
`;

const FloatingElements = styled.div`
  position: absolute;
  width: 100%;
  height: 100%;
  overflow: hidden;
  pointer-events: none;
`;

const FloatingDot = styled(motion.div)`
  position: absolute;
  width: 4px;
  height: 4px;
  background: rgba(255, 215, 0, 0.6);
  border-radius: 50%;
`;

const BottomAccent = styled.div`
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 2px;
  background: linear-gradient(90deg, 
    transparent 0%, 
    rgba(255, 215, 0, 0.5) 25%, 
    rgba(255, 215, 0, 0.8) 50%, 
    rgba(255, 215, 0, 0.5) 75%, 
    transparent 100%
  );
`;

const IntroView = ({ onContinue }) => {
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        duration: 1,
        staggerChildren: 0.3
      }
    }
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 30 },
    visible: {
      opacity: 1,
      y: 0,
      transition: { duration: 0.8, ease: "easeOut" }
    }
  };

  return (
    <Container>
      <FilmGrainOverlay />
      <VintageFrame />
      
      <FloatingElements>
        {[...Array(12)].map((_, i) => (
          <FloatingDot
            key={i}
            animate={{
              x: [0, Math.random() * 100 - 50],
              y: [0, Math.random() * 100 - 50],
              opacity: [0.3, 0.8, 0.3]
            }}
            transition={{
              duration: 4 + Math.random() * 4,
              repeat: Infinity,
              delay: Math.random() * 2
            }}
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`
            }}
          />
        ))}
      </FloatingElements>

      <ContentWrapper
        variants={containerVariants}
        initial="hidden"
        animate={mounted ? "visible" : "hidden"}
      >
        <LogoContainer variants={itemVariants}>
          <LogoGlow />
          <Logo
            animate={{
              rotate: [0, 1, -1, 0],
              scale: [1, 1.02, 1]
            }}
            transition={{
              duration: 6,
              repeat: Infinity,
              ease: "easeInOut"
            }}
          >
            📹
          </Logo>
        </LogoContainer>
        
        <Title variants={itemVariants}>
          Be the director...
          <br />
          and the star
        </Title>
        
        <Subtitle variants={itemVariants}>
          Basically just your mom's old home video camera that you and your friends can share
        </Subtitle>
        
        <GetStartedButton
          variants={itemVariants}
          onClick={onContinue}
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        >
          Get Started
        </GetStartedButton>
      </ContentWrapper>

      <BottomAccent />
    </Container>
  );
};

export default IntroView;