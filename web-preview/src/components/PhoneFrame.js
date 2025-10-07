import React from 'react';
import styled from 'styled-components';

const PhoneContainer = styled.div`
  width: 375px;
  height: 812px;
  background: #000;
  border-radius: 40px;
  padding: 10px;
  box-shadow: 0 0 30px rgba(0, 0, 0, 0.5);
  position: relative;
  overflow: hidden;
`;

const Screen = styled.div`
  width: 100%;
  height: 100%;
  background: #000;
  border-radius: 30px;
  overflow: hidden;
  position: relative;
`;

const Notch = styled.div`
  position: absolute;
  top: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 150px;
  height: 30px;
  background: #000;
  border-radius: 0 0 20px 20px;
  z-index: 100;
`;

const StatusBar = styled.div`
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 44px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
  color: white;
  font-size: 14px;
  font-weight: 600;
  z-index: 99;
`;

const HomeIndicator = styled.div`
  position: absolute;
  bottom: 8px;
  left: 50%;
  transform: translateX(-50%);
  width: 134px;
  height: 5px;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 3px;
`;

const Content = styled.div`
  padding-top: 44px;
  padding-bottom: 34px;
  height: calc(100% - 78px);
  overflow-y: auto;
`;

const PhoneFrame = ({ children }) => {
  return (
    <PhoneContainer>
      <Screen>
        <Notch />
        <StatusBar>
          <span>9:41</span>
          <span>100% 🔋</span>
        </StatusBar>
        <Content>
          {children}
        </Content>
        <HomeIndicator />
      </Screen>
    </PhoneContainer>
  );
};

export default PhoneFrame;