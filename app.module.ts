import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';

@Module({
  imports: [], // Future microservices like BookingModule, ErpSyncModule will go here
    controllers: [AppController], // Handles incoming requests from the app
      providers: [AppService], // Handles the business logic and database communication
      })
      export class AppModule {}
      